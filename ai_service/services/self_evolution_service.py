import logging
from typing import List, Tuple

from core.schema import HealthDataInput, HealthEvaluationResponse
from core.utils import build_features, compare_daily

logger = logging.getLogger(__name__)


STATUS_MAP = {
    "xau": "xấu",
    "binh_thuong": "bình thường",
    "tot": "tốt",
}


class SelfEvolutionService:
    def __init__(self, model_bundle: dict = None):
        self.model = model_bundle.get("model") if model_bundle else None
        self.features_cols = model_bundle.get("features") if model_bundle else None
        self.use_model = self.model is not None and self.features_cols is not None

        self.safe_thresholds = {
            "spo2": 92.0,
            "heart_rate": 120.0,
            "sleep_hours": 4.0,
        }
        self.deadband_ratio = 0.03  # ±3%

    # -----------------------------
    # Utilities
    # -----------------------------
    def _to_vi_status(self, status: str) -> str:
        return STATUS_MAP.get(status, "bình thường")

    def _apply_ema(self, current: dict, history: List[dict], alpha: float = 0.5) -> dict:
        ema_keys = ["heart_rate", "spo2", "sleep_hours", "hrv"]
        smoothed = dict(current)

        recent = history[-2:] if history else []

        for key in ema_keys:
            seq = []
            for h in recent:
                val = float(h.get(key, 0) or 0)
                if val > 0:
                    seq.append(val)

            cur_val = float(current.get(key, 0) or 0)
            if cur_val > 0:
                seq.append(cur_val)

            if not seq:
                continue

            ema = seq[0]
            for v in seq[1:]:
                ema = alpha * v + (1 - alpha) * ema
            smoothed[key] = ema

        return smoothed

    def _deadband_bounds(self, threshold: float) -> Tuple[float, float]:
        delta = threshold * self.deadband_ratio
        return threshold - delta, threshold + delta

    # -----------------------------
    # Rule layers
    # -----------------------------
    def safety_rule(self, current: dict) -> dict:
        reasons = []

        spo2 = float(current.get("spo2", 0) or 0)
        hr = float(current.get("heart_rate", 0) or 0)
        sleep = float(current.get("sleep_hours", 0) or 0)

        spo2_low, _ = self._deadband_bounds(self.safe_thresholds["spo2"])
        _, hr_high = self._deadband_bounds(self.safe_thresholds["heart_rate"])
        sleep_low, _ = self._deadband_bounds(self.safe_thresholds["sleep_hours"])

        if spo2 > 0 and spo2 < spo2_low:
            reasons.append(f"SpO2 thấp nguy hiểm ({spo2:.1f} < {spo2_low:.1f})")
        if hr > hr_high:
            reasons.append(f"Nhịp tim cao nguy hiểm ({hr:.1f} > {hr_high:.1f})")
        if sleep > 0 and sleep < sleep_low:
            reasons.append(f"Thiếu ngủ nghiêm trọng ({sleep:.1f}h < {sleep_low:.1f}h)")

        return {"matched": len(reasons) > 0, "reason": reasons}

    def good_zone_gate(self, current: dict) -> dict:
        hr = float(current.get("heart_rate", 0) or 0)
        spo2 = float(current.get("spo2", 0) or 0)
        sleep = float(current.get("sleep_hours", 0) or 0)
        hrv = float(current.get("hrv", 0) or 0)
        steps = float(current.get("steps", 0) or 0)

        conditions = [
            60 <= hr <= 80,
            spo2 >= 97,
            7 <= sleep <= 8.5,
            hrv >= 40,
            steps >= 8000,
        ]

        if sum(conditions) >= 4:
            return {
                "matched": True,
                "reason": ["Các chỉ số đang nằm trong vùng sức khỏe tốt"],
            }

        return {"matched": False, "reason": []}

    def baseline_normal_gate(self, current: dict) -> dict:
        hr = float(current.get("heart_rate", 0) or 0)
        spo2 = float(current.get("spo2", 0) or 0)
        sleep = float(current.get("sleep_hours", 0) or 0)
        hrv = float(current.get("hrv", 0) or 0)

        in_hr = 60 <= hr <= 100
        in_spo2 = 95 <= spo2 <= 100
        in_sleep = 6 <= sleep <= 9
        in_hrv = 25 <= hrv <= 80

        if in_hr and in_spo2 and in_sleep and in_hrv:
            return {
                "matched": True,
                "reason": ["Các chỉ số nằm trong baseline người bình thường"],
            }

        return {"matched": False, "reason": []}

    def _near_safety_deadband(self, current: dict) -> bool:
        spo2 = float(current.get("spo2", 0) or 0)
        hr = float(current.get("heart_rate", 0) or 0)
        sleep = float(current.get("sleep_hours", 0) or 0)

        low_spo2, high_spo2 = self._deadband_bounds(self.safe_thresholds["spo2"])
        low_hr, high_hr = self._deadband_bounds(self.safe_thresholds["heart_rate"])
        low_sleep, high_sleep = self._deadband_bounds(self.safe_thresholds["sleep_hours"])

        spo2_band = spo2 > 0 and low_spo2 <= spo2 <= high_spo2
        hr_band = low_hr <= hr <= high_hr
        sleep_band = sleep > 0 and low_sleep <= sleep <= high_sleep

        return spo2_band or hr_band or sleep_band

    def _near_good_deadband(self, current: dict) -> bool:
        hr = float(current.get("heart_rate", 0) or 0)
        spo2 = float(current.get("spo2", 0) or 0)
        sleep = float(current.get("sleep_hours", 0) or 0)
        hrv = float(current.get("hrv", 0) or 0)
        steps = float(current.get("steps", 0) or 0)

        def in_band(value: float, threshold: float) -> bool:
            low, high = self._deadband_bounds(threshold)
            return low <= value <= high

        hr_band = in_band(hr, 60) or in_band(hr, 80)
        spo2_band = in_band(spo2, 97)
        sleep_band = in_band(sleep, 7) or in_band(sleep, 8.5)
        hrv_band = in_band(hrv, 40)
        steps_band = in_band(steps, 8000)

        return hr_band or spo2_band or sleep_band or hrv_band or steps_band

    def _classify_for_hysteresis(self, day: dict) -> str:
        safety = self.safety_rule(day)
        if safety["matched"]:
            return "xau"

        good_zone = self.good_zone_gate(day)
        if good_zone["matched"]:
            return "tot"

        baseline = self.baseline_normal_gate(day)
        if baseline["matched"]:
            return "binh_thuong"

        return "unknown"

    def apply_hysteresis(self, proposed_status: str, current: dict, history: List[dict]) -> str:
        if not history:
            return proposed_status

        prev1 = history[-1]
        prev2 = history[-2] if len(history) >= 2 else None

        prev1_status = self._classify_for_hysteresis(prev1)
        prev2_status = self._classify_for_hysteresis(prev2) if prev2 else "unknown"

        if self._near_safety_deadband(current) and prev1_status in {"binh_thuong", "xau"}:
            return prev1_status

        if self._near_good_deadband(current) and prev1_status in {"tot", "binh_thuong"}:
            return prev1_status

        # bình thường <-> xấu
        if proposed_status == "xau" and prev1_status != "xau":
            if prev1_status == "xau" or prev2_status == "xau":
                return proposed_status
            return "binh_thuong"

        if proposed_status == "binh_thuong" and prev1_status == "xau":
            if prev1_status == "binh_thuong" and prev2_status == "binh_thuong":
                return proposed_status
            return "xau"

        # tốt <-> bình thường
        if proposed_status == "tot" and prev1_status != "tot":
            if prev1_status == "tot" or prev2_status == "tot":
                return proposed_status
            return "binh_thuong"

        if proposed_status == "binh_thuong" and prev1_status == "tot":
            if prev2_status == "tot":
                return "tot"
            return proposed_status

        return proposed_status

    # -----------------------------
    # Messaging
    # -----------------------------
    def _build_output_text(self, status: str, reason: List[str]) -> Tuple[str, str]:
        if status == "tot":
            return (
                "Các chỉ số sức khỏe hôm nay đang tích cực.",
                "Tiếp tục duy trì vận động, giấc ngủ điều độ và theo dõi chỉ số hằng ngày.",
            )

        if status == "xau":
            if reason:
                return (
                    f"Một số chỉ số sức khỏe đang ở mức cần chú ý: {reason[0]}.",
                    "Nên nghỉ ngơi, theo dõi lại trong ngày và liên hệ chuyên gia y tế nếu bất thường kéo dài.",
                )
            return (
                "Một số chỉ số sức khỏe đang ở mức cần chú ý.",
                "Nên nghỉ ngơi, theo dõi lại trong ngày và liên hệ chuyên gia y tế nếu bất thường kéo dài.",
            )

        return (
            "Tình trạng sức khỏe hiện tại ở mức bình thường.",
            "Duy trì thói quen sinh hoạt ổn định và tiếp tục theo dõi định kỳ.",
        )

    def _resp(self, status: str, message: str, advice: str, compare: dict) -> HealthEvaluationResponse:
        return HealthEvaluationResponse(
            status=self._to_vi_status(status),
            message=message,
            advice=advice,
            compare=compare,
        )

    # -----------------------------
    # Main pipeline
    # -----------------------------
    def predict(self, data: HealthDataInput) -> HealthEvaluationResponse:
        try:
            current_raw = (
                data.current_metrics.model_dump()
                if hasattr(data.current_metrics, "model_dump")
                else data.current_metrics.dict()
            )
            history_objs = data.history or []
            history_raw = [h.model_dump() if hasattr(h, "model_dump") else h.dict() for h in history_objs]

            current = self._apply_ema(current_raw, history_raw)
            compare = compare_daily(current_raw, history_raw)

            # 1) SAFETY RULE (HARD LOCK - RETURN IMMEDIATELY)
            safety = self.safety_rule(current)
            if safety["matched"]:
                message, advice = self._build_output_text("xau", safety["reason"])
                return self._resp("xau", message, advice, compare)

            # 2) COMPUTE CANDIDATE STATUS (NO EARLY RETURN)
            good_zone = self.good_zone_gate(current)
            baseline = self.baseline_normal_gate(current)

            if good_zone["matched"]:
                candidate_status = "tot"
                candidate_reason = good_zone["reason"]
            elif baseline["matched"]:
                candidate_status = "binh_thuong"
                candidate_reason = baseline["reason"]
            else:
                # 3) MODEL PREDICTION (fallback region)
                if self.use_model and len(history_raw) >= 1:
                    f = build_features(current, history_raw)
                    X = [[f.get(col, 0) for col in self.features_cols]]
                    pred = self.model.predict(X)[0]
                    candidate_status = {0: "xau", 1: "binh_thuong", 2: "tot"}.get(int(pred), "binh_thuong")
                    candidate_reason = []
                else:
                    candidate_status = "binh_thuong"
                    candidate_reason = []

            # 4) HYSTERESIS + DEADBAND (APPLY FOR ALL NON-SAFETY)
            final_status = self.apply_hysteresis(candidate_status, current, history_raw)

            message, advice = self._build_output_text(final_status, candidate_reason)
            return self._resp(final_status, message, advice, compare)

        except Exception as e:
            logger.error(f"Predict Error: {e}", exc_info=True)
            message, advice = self._build_output_text("binh_thuong", [])
            return self._resp("binh_thuong", message, advice, {})
