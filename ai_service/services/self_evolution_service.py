import logging
from statistics import mean, median, pstdev
from typing import Dict, List, Tuple, Optional

from core.schema import HealthDataInput, HealthEvaluationResponse
from core.utils import process_history
from services.ml_support import MLSupport

logger = logging.getLogger(__name__)


class SelfEvolutionService:
    # ===== Safety layer (explicitly allowed hard thresholds) =====
    SAFETY_THRESHOLDS = {
        "spo2_critical_low": 90.0,
        "heart_rate_critical_low": 40.0,
        "heart_rate_critical_high": 130.0,
        "sleep_critical_low": 3.5,
    }

    # ===== Time windows =====
    BASELINE_WINDOW_DAYS = 7
    TREND_WINDOW_DAYS = 3

    # ===== Metric config =====
    METRIC_CFG = {
        "heart_rate": {"higher_is_better": False, "weight": 1.2, "label": "Nhịp tim", "unit": "bpm"},
        "sleep_hours": {"higher_is_better": True, "weight": 1.1, "label": "Giấc ngủ", "unit": "giờ"},
        "steps": {"higher_is_better": True, "weight": 1.0, "label": "Số bước", "unit": "bước"},
        "distance": {"higher_is_better": True, "weight": 0.8, "label": "Quãng đường", "unit": "km"},
        "spo2": {"higher_is_better": True, "weight": 1.4, "label": "SpO2", "unit": "%"},
        "hrv": {"higher_is_better": True, "weight": 1.0, "label": "HRV", "unit": "ms"},
    }

    # ===== Decision constants =====
    SCORE_GOOD_HIGH_CONF = 0.28
    SCORE_BAD_HIGH_CONF = -0.28
    SCORE_GOOD_LOW_CONF = 0.40
    SCORE_BAD_LOW_CONF = -0.40

    TREND_NOISE_RATIO = 0.02

    # ===== Hybrid ML support =====
    ML_NEAR_ZERO_THRESHOLD = 0.35
    ML_ADJUST_STEP = 0.20
    ML_SCORE_CAP = 0.20

    def __init__(self, model_bundle: dict = None):
        self.model_bundle = model_bundle or {}
        self.ml_support = MLSupport(self.model_bundle)

        # Shadow mode default ON: log-only, no user-facing impact
        self.ml_shadow_mode = bool(self.model_bundle.get("ml_shadow_mode", True))

    # ------------------------------------------------------------
    # Output helpers
    # ------------------------------------------------------------
    def _to_vi_trangthai(self, trangthai: str) -> str:
        mapping = {
            "good": "tốt",
            "normal": "bình thường",
            "bad": "xấu",
        }
        return mapping.get(trangthai, "bình thường")

    def _resp(
        self,
        trangthai: str,
        thongdiep: str,
        loikhuyen: str,
        sosanh: Optional[Dict[str, str]],
    ) -> HealthEvaluationResponse:
        safe_sosanh = sosanh if isinstance(sosanh, dict) else {}
        return HealthEvaluationResponse(
            trangthai=self._to_vi_trangthai((trangthai or "normal").strip().lower()),
            thongdiep=(thongdiep or "").strip(),
            loikhuyen=(loikhuyen or "").strip(),
            sosanh=safe_sosanh,
        )

    # ------------------------------------------------------------
    # Core compute blocks (kept architecture)
    # ------------------------------------------------------------
    def compute_confidence(self, history_count: int) -> str:
        if history_count <= 0:
            return "insufficient"
        if 1 <= history_count <= 4:
            return "low"
        return "high"

    def _trimmed_values(self, values: List[float], ratio: float = 0.1) -> List[float]:
        if not values:
            return []
        if len(values) < 5:
            return values

        s = sorted(values)
        k = max(int(len(s) * ratio), 1)
        if len(s) - 2 * k <= 0:
            return s
        return s[k:-k]

    def compute_baseline(self, history: List[dict]) -> Dict[str, Dict[str, float]]:
        if not history:
            return {}

        recent = history[-self.BASELINE_WINDOW_DAYS :]
        baseline: Dict[str, Dict[str, float]] = {}

        for metric in self.METRIC_CFG.keys():
            values = [float(d.get(metric, 0) or 0) for d in recent if float(d.get(metric, 0) or 0) > 0]
            if not values:
                continue

            trimmed = self._trimmed_values(values)
            center = median(trimmed)
            sigma = pstdev(trimmed) if len(trimmed) > 1 else 0.0

            baseline[metric] = {
                "mean": center,
                "std": sigma,
                "count": float(len(trimmed)),
            }

        return baseline

    def _clip(self, x: float, lo: float, hi: float) -> float:
        return max(lo, min(hi, x))

    def compute_deviation(self, current: dict, baseline: Dict[str, Dict[str, float]]) -> Dict[str, Dict[str, float]]:
        result: Dict[str, Dict[str, float]] = {}

        for metric, cfg in self.METRIC_CFG.items():
            curr = float(current.get(metric, 0) or 0)
            b = baseline.get(metric)
            if curr <= 0 or not b:
                continue

            mu = float(b["mean"])
            std = float(b["std"])
            raw_dev = curr - mu

            pct_dev = (raw_dev / mu) if mu > 0 else 0.0
            z = (raw_dev / std) if std > 1e-6 else 0.0

            oriented_pct = pct_dev if cfg["higher_is_better"] else -pct_dev
            oriented_z = z if cfg["higher_is_better"] else -z

            # normalized impact range ~[-1,1]
            if abs(oriented_z) > 1e-6:
                normalized = self._clip(oriented_z / 3.0, -1.0, 1.0)
            else:
                normalized = self._clip(oriented_pct * 2.0, -1.0, 1.0)

            result[metric] = {
                "current": curr,
                "baseline": mu,
                "raw_dev": raw_dev,
                "pct_dev": pct_dev,
                "zscore": z,
                "oriented_pct": oriented_pct,
                "oriented_z": oriented_z,
                "normalized": normalized,
            }

        return result

    def compute_trend(self, history: List[dict], current: dict) -> Dict[str, str]:
        trend: Dict[str, str] = {}

        for metric, cfg in self.METRIC_CFG.items():
            seq = [float(d.get(metric, 0) or 0) for d in history[-(self.TREND_WINDOW_DAYS - 1) :]]
            seq.append(float(current.get(metric, 0) or 0))
            seq = [v for v in seq if v > 0]

            if len(seq) < self.TREND_WINDOW_DAYS:
                trend[metric] = "stable"
                continue

            a, b, c = seq[-3], seq[-2], seq[-1]
            avg = max((a + b + c) / 3, 1e-6)

            d1 = (b - a) / avg
            d2 = (c - b) / avg

            up_cnt = int(d1 > self.TREND_NOISE_RATIO) + int(d2 > self.TREND_NOISE_RATIO)
            down_cnt = int(d1 < -self.TREND_NOISE_RATIO) + int(d2 < -self.TREND_NOISE_RATIO)

            increasing = up_cnt >= 2
            decreasing = down_cnt >= 2

            if cfg["higher_is_better"]:
                if increasing:
                    trend[metric] = "improving"
                elif decreasing:
                    trend[metric] = "worsening"
                else:
                    trend[metric] = "stable"
            else:
                if decreasing:
                    trend[metric] = "improving"
                elif increasing:
                    trend[metric] = "worsening"
                else:
                    trend[metric] = "stable"

        return trend

    def safety_layer(self, current: dict) -> Tuple[bool, List[str]]:
        reasons = []

        spo2 = float(current.get("spo2", 0) or 0)
        hr = float(current.get("heart_rate", 0) or 0)
        sleep = float(current.get("sleep_hours", 0) or 0)

        if spo2 > 0 and spo2 < self.SAFETY_THRESHOLDS["spo2_critical_low"]:
            reasons.append("SpO2 ở mức nguy hiểm")

        if hr > 0 and (
            hr < self.SAFETY_THRESHOLDS["heart_rate_critical_low"]
            or hr > self.SAFETY_THRESHOLDS["heart_rate_critical_high"]
        ):
            reasons.append("Nhịp tim ở mức bất thường nguy hiểm")

        if sleep > 0 and sleep < self.SAFETY_THRESHOLDS["sleep_critical_low"]:
            reasons.append("Thời gian ngủ quá thấp")

        return (len(reasons) > 0, reasons)

    def _compute_prev_trangthai(self, history: List[dict], confidence: str, baseline: Dict[str, Dict[str, float]]) -> str:
        if not history:
            return "normal"

        prev_current = history[-1]
        prev_hist = history[:-1]

        prev_base = self.compute_baseline(prev_hist) if prev_hist else baseline
        prev_dev = self.compute_deviation(prev_current, prev_base)
        prev_tr = self.compute_trend(prev_hist, prev_current)

        trangthai, _ = self._decision_core(prev_dev, prev_tr, confidence)
        return trangthai

    def _decision_core(self, deviations: Dict[str, Dict[str, float]], trends: Dict[str, str], confidence: str) -> Tuple[str, Dict[str, float]]:
        if not deviations:
            return "normal", {"score": 0.0, "improving": 0.0, "worsening": 0.0}

        # unbiased combine: mean of normalized metrics
        normalized_values = [float(d.get("normalized", 0.0)) for d in deviations.values()]
        core_score = mean(normalized_values) if normalized_values else 0.0

        total = max(len(trends), 1)
        improving_ratio = sum(1 for t in trends.values() if t == "improving") / total
        worsening_ratio = sum(1 for t in trends.values() if t == "worsening") / total

        if confidence == "high":
            good_cut = self.SCORE_GOOD_HIGH_CONF
            bad_cut = self.SCORE_BAD_HIGH_CONF
        else:
            good_cut = self.SCORE_GOOD_LOW_CONF
            bad_cut = self.SCORE_BAD_LOW_CONF

        if core_score >= good_cut and improving_ratio >= 0.45:
            return "good", {"score": core_score, "improving": improving_ratio, "worsening": worsening_ratio}

        if core_score <= bad_cut and worsening_ratio >= 0.45:
            return "bad", {"score": core_score, "improving": improving_ratio, "worsening": worsening_ratio}

        return "normal", {"score": core_score, "improving": improving_ratio, "worsening": worsening_ratio}

    def _integrate_ml(
        self,
        core_score: float,
        confidence: str,
        safety_trigger: bool,
        deviations: Dict[str, Dict[str, float]],
        trends: Dict[str, str],
        baseline: Dict[str, Dict[str, float]],
    ) -> Tuple[float, Dict[str, float]]:
        # Gating condition (required)
        use_ml = (
            (not safety_trigger)
            and confidence != "insufficient"
            and abs(core_score) < self.ML_NEAR_ZERO_THRESHOLD
        )

        ml_output = {"risk_score": 0.0, "anomaly_score": 0.0, "uncertainty": False}
        adjusted_score = core_score

        if not use_ml:
            return adjusted_score, ml_output

        ml_output = self.ml_support.infer(
            deviations=deviations,
            trends=trends,
            baseline=baseline,
            confidence=confidence,
            core_score=core_score,
        )

        # Shadow mode: log-only, không ảnh hưởng user-facing decision
        if self.ml_shadow_mode:
            logger.info(f"[ML-SHADOW] core_score={core_score:.3f} ml={ml_output}")
            return adjusted_score, ml_output

        delta = 0.0
        if ml_output.get("anomaly_score", 0.0) > 0.7:
            delta -= self.ML_ADJUST_STEP

        if ml_output.get("risk_score", 0.0) > 0.7:
            delta -= self.ML_ADJUST_STEP

        delta = self._clip(delta, -self.ML_SCORE_CAP, self.ML_SCORE_CAP)

        adjusted_score = core_score + delta

        if ml_output.get("uncertainty", False):
            adjusted_score *= 0.85

        return adjusted_score, ml_output

    def _trangthai_from_score(self, score: float, improving_ratio: float, worsening_ratio: float, confidence: str) -> str:
        if confidence == "high":
            good_cut = self.SCORE_GOOD_HIGH_CONF
            bad_cut = self.SCORE_BAD_HIGH_CONF
        else:
            good_cut = self.SCORE_GOOD_LOW_CONF
            bad_cut = self.SCORE_BAD_LOW_CONF

        if score >= good_cut and improving_ratio >= 0.45:
            return "good"
        if score <= bad_cut and worsening_ratio >= 0.45:
            return "bad"
        return "normal"

    def _apply_hysteresis(self, prev_trangthai: str, candidate_trangthai: str, score: float, confidence: str) -> str:
        margin = 0.08 if confidence == "high" else 0.12

        if prev_trangthai == "bad" and candidate_trangthai == "normal" and score < margin:
            return "bad"

        if prev_trangthai == "good" and candidate_trangthai == "normal" and score > -margin:
            return "good"

        if prev_trangthai == "normal" and candidate_trangthai == "good" and score < (self.SCORE_GOOD_HIGH_CONF + margin):
            return "normal"

        if prev_trangthai == "normal" and candidate_trangthai == "bad" and score > (self.SCORE_BAD_HIGH_CONF - margin):
            return "normal"

        return candidate_trangthai

    def decision_engine(
        self,
        deviations: Dict[str, Dict[str, float]],
        trends: Dict[str, str],
        confidence: str,
        safety_trigger: bool = False,
        baseline: Optional[Dict[str, Dict[str, float]]] = None,
        history: Optional[List[dict]] = None,
    ) -> Tuple[str, Dict[str, float]]:
        baseline = baseline or {}
        history = history or []

        core_trangthai, core_diag = self._decision_core(deviations, trends, confidence)
        core_score = float(core_diag.get("score", 0.0))

        final_score, ml_output = self._integrate_ml(
            core_score=core_score,
            confidence=confidence,
            safety_trigger=safety_trigger,
            deviations=deviations,
            trends=trends,
            baseline=baseline,
        )

        improving_ratio = float(core_diag.get("improving", 0.0))
        worsening_ratio = float(core_diag.get("worsening", 0.0))

        candidate_trangthai = self._trangthai_from_score(final_score, improving_ratio, worsening_ratio, confidence)

        prev_trangthai = self._compute_prev_trangthai(history, confidence, baseline)
        final_trangthai = self._apply_hysteresis(prev_trangthai, candidate_trangthai, final_score, confidence)

        return final_trangthai, {
            "score": final_score,
            "core_score": core_score,
            "improving": improving_ratio,
            "worsening": worsening_ratio,
            "ml_risk_score": float(ml_output.get("risk_score", 0.0)),
            "ml_anomaly_score": float(ml_output.get("anomaly_score", 0.0)),
            "ml_uncertainty": 1.0 if ml_output.get("uncertainty", False) else 0.0,
            "core_trangthai_id": 1.0 if core_trangthai == "good" else -1.0 if core_trangthai == "bad" else 0.0,
        }

    # ------------------------------------------------------------
    # Presentation helpers
    # ------------------------------------------------------------
    def build_sosanh(self, deviations: Dict[str, Dict[str, float]]) -> Dict[str, str]:
        sosanh: Dict[str, str] = {}
        for metric, d in deviations.items():
            cfg = self.METRIC_CFG[metric]
            current = d["current"]
            raw_dev = d["raw_dev"]

            if abs(raw_dev) <= 1e-3:
                trang_thai = "ổn định"
            elif raw_dev > 0:
                trang_thai = "tăng"
            else:
                trang_thai = "giảm"

            sosanh[metric] = f"{cfg['label']}: {current:.1f}{cfg['unit']} ({trang_thai} so với bình thường)"

        return sosanh

    def build_thongdiep_loikhuyen(self, trangthai: str, confidence: str, diagnostics: Dict[str, float], safety_reasons: List[str]) -> Tuple[str, str]:
        if confidence in ("insufficient", "low"):
            return (
                "Dữ liệu chưa đủ để đánh giá chính xác.",
                "Hãy tiếp tục ghi nhận thêm trong vài ngày tới.",
            )

        if trangthai == "bad":
            if safety_reasons:
                return (
                    f"Phát hiện dấu hiệu bất thường: {', '.join(safety_reasons)}.",
                    "Nên nghỉ ngơi, theo dõi thêm và điều chỉnh sinh hoạt.",
                )
            return (
                "Một số chỉ số của bạn đang có dấu hiệu giảm.",
                "Nên nghỉ ngơi, theo dõi thêm và điều chỉnh sinh hoạt.",
            )

        if trangthai == "good":
            return (
                "Các chỉ số sức khỏe của bạn đang tốt.",
                "Hãy tiếp tục duy trì thói quen hiện tại.",
            )

        return (
            "Tình trạng sức khỏe của bạn đang ổn định.",
            "Tiếp tục duy trì vận động, ngủ đủ giấc và theo dõi thường xuyên.",
        )

    # ------------------------------------------------------------
    # Main entry
    # ------------------------------------------------------------
    def predict(self, data: HealthDataInput) -> HealthEvaluationResponse:
        try:
            current = (
                data.current_metrics.model_dump()
                if hasattr(data.current_metrics, "model_dump")
                else data.current_metrics.dict()
            )
            history = [h.model_dump() if hasattr(h, "model_dump") else h.dict() for h in (data.history or [])]

            df_hist = process_history(history)
            history_sorted = df_hist.to_dict("records") if not df_hist.empty else []

            confidence = self.compute_confidence(len(history_sorted))

            if confidence == "insufficient":
                thongdiep, loikhuyen = self.build_thongdiep_loikhuyen("normal", confidence, {}, [])
                return self._resp("normal", thongdiep, loikhuyen, {})

            is_safety, safety_reasons = self.safety_layer(current)
            baseline = self.compute_baseline(history_sorted)
            deviations = self.compute_deviation(current, baseline)
            sosanh = self.build_sosanh(deviations)

            if is_safety:
                thongdiep, loikhuyen = self.build_thongdiep_loikhuyen("bad", confidence, {}, safety_reasons)
                return self._resp("bad", thongdiep, loikhuyen, sosanh)

            trends = self.compute_trend(history_sorted, current)
            trangthai, diagnostics = self.decision_engine(
                deviations=deviations,
                trends=trends,
                confidence=confidence,
                safety_trigger=is_safety,
                baseline=baseline,
                history=history_sorted,
            )

            thongdiep, loikhuyen = self.build_thongdiep_loikhuyen(trangthai, confidence, diagnostics, [])
            return self._resp(trangthai, thongdiep, loikhuyen, sosanh)

        except Exception as e:
            logger.error(f"Predict Error: {e}", exc_info=True)
            return self._resp(
                "normal",
                "Có lỗi trong quá trình phân tích, tạm thời trả kết quả bình thường.",
                "Vui lòng thử lại sau và tiếp tục theo dõi dữ liệu hằng ngày.",
                {},
            )
