from __future__ import annotations

from typing import Dict, Any, Optional


class MLSupport:


    def __init__(self, model_bundle: Optional[Dict[str, Any]] = None):
        self.model_bundle = model_bundle or {}
        self.risk_model = self.model_bundle.get("risk_model")
        self.anomaly_model = self.model_bundle.get("anomaly_model")

    @staticmethod
    def _clamp01(x: float) -> float:
        if x < 0.0:
            return 0.0
        if x > 1.0:
            return 1.0
        return float(x)

    def _build_feature_vector(
        self,
        deviations: Dict[str, Dict[str, float]],
        trends: Dict[str, str],
        baseline: Dict[str, Dict[str, float]],
        confidence: str,
        core_score: float,
    ) -> list[float]:
        metric_order = ["heart_rate", "sleep_hours", "steps", "distance", "spo2", "hrv"]

        vec = []
        for m in metric_order:
            d = deviations.get(m, {})
            vec.append(float(d.get("normalized", 0.0)))

        for m in metric_order:
            tr = trends.get(m, "stable")
            vec.append(1.0 if tr == "worsening" else -1.0 if tr == "improving" else 0.0)

        for m in metric_order:
            b = baseline.get(m, {})
            vec.append(float(b.get("std", 0.0)))

        conf_val = 0.0 if confidence == "insufficient" else 0.5 if confidence == "low" else 1.0
        vec.append(conf_val)
        vec.append(float(core_score))

        return vec

    def _heuristic_scores(
        self,
        deviations: Dict[str, Dict[str, float]],
        trends: Dict[str, str],
        confidence: str,
        core_score: float,
    ) -> Dict[str, Any]:
        if not deviations:
            return {"risk_score": 0.0, "anomaly_score": 0.0, "uncertainty": True}

        vals = [abs(float(d.get("normalized", 0.0))) for d in deviations.values()]
        avg_abs = sum(vals) / max(len(vals), 1)

        worsening = sum(1 for t in trends.values() if t == "worsening")
        trend_ratio = worsening / max(len(trends), 1)

        risk_score = self._clamp01(0.55 * avg_abs + 0.35 * trend_ratio + 0.10 * max(-core_score, 0.0))
        anomaly_score = self._clamp01(max(vals) * 0.7 + trend_ratio * 0.3)

        uncertainty = confidence == "low" and avg_abs < 0.25

        return {
            "risk_score": float(risk_score),
            "anomaly_score": float(anomaly_score),
            "uncertainty": bool(uncertainty),
        }

    def infer(
        self,
        deviations: Dict[str, Dict[str, float]],
        trends: Dict[str, str],
        baseline: Dict[str, Dict[str, float]],
        confidence: str,
        core_score: float,
    ) -> Dict[str, Any]:
        # Default safe heuristic output
        fallback = self._heuristic_scores(deviations, trends, confidence, core_score)

        # If external models are not configured, return fallback
        if self.risk_model is None and self.anomaly_model is None:
            return fallback

        try:
            vec = self._build_feature_vector(deviations, trends, baseline, confidence, core_score)

            risk_score = fallback["risk_score"]
            anomaly_score = fallback["anomaly_score"]

            if self.risk_model is not None:
                if hasattr(self.risk_model, "predict_proba"):
                    risk_score = float(self.risk_model.predict_proba([vec])[0][1])
                else:
                    risk_score = float(self.risk_model.predict([vec])[0])

            if self.anomaly_model is not None:
                # sklearn-style decision_function: higher is more normal.
                if hasattr(self.anomaly_model, "decision_function"):
                    d = float(self.anomaly_model.decision_function([vec])[0])
                    anomaly_score = self._clamp01(1.0 / (1.0 + (2.718281828 ** d)))
                else:
                    anomaly_score = float(self.anomaly_model.predict([vec])[0])

            out = {
                "risk_score": self._clamp01(risk_score),
                "anomaly_score": self._clamp01(anomaly_score),
                "uncertainty": bool(fallback["uncertainty"]),
            }
            return out
        except Exception:
            return fallback
