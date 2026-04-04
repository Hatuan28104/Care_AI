import logging
from core.schema import HealthDataInput, HealthEvaluationResponse, DailyHealthRecord
from core.utils import build_features, compare_daily

logger = logging.getLogger(__name__)

class SelfEvolutionService:
    def __init__(self, model_bundle: dict = None):
        self.model = model_bundle.get("model") if model_bundle else None
        self.features_cols = model_bundle.get("features") if model_bundle else None
        self.use_model = self.model is not None and self.features_cols is not None

    def evaluate_health_rule_based(self, f: dict) -> str:
        if f["sleep_diff"] < -1 or f["hr_diff"] > 10 or f["spo2_diff"] < -2:
            return "bad"
        if f["steps_diff"] > 1000 and f["sleep_diff"] > 0 and f["hrv_diff"] > 5:
            return "good"
        return "normal"

    def build_response_msg(self, status: str) -> dict:
        messages = {
            "bad": {
                "message": "Trạng thái hôm nay có vẻ đang mệt mỏi",
                "advice": "Hãy thư giãn sớm, cố gắng ngủ đủ giấc và theo dõi sức khỏe nhé!"
            },
            "good": {
                "message": "Phong độ hôm nay vô cùng tuyệt vời",
                "advice": "Cơ thể bạn đang rất dồi dào năng lượng. Hãy tiếp tục duy trì!"
            },
            "normal": {
                "message": "Mọi chỉ số đều đang duy trì ổn định",
                "advice": "Nhớ đi bộ nhẹ nhàng và nạp thêm đủ nước cho ngày dài nhé."
            }
        }
        resp = messages.get(status, {
            "message": "Hệ thống đang tinh chỉnh để hiểu thói quen của bạn",
            "advice": "Hãy đeo đồng hồ thêm vài ngày để nhận được những phân tích cực chuẩn nhé."
        })
        resp["status"] = status
        return resp

    def predict(self, data: HealthDataInput) -> HealthEvaluationResponse:
        try:
            current_data = data.current_metrics.model_dump() if hasattr(data.current_metrics, "model_dump") else data.current_metrics.dict()
            history = data.history or []

            if len(history) < 1:
                resp = self.build_response_msg("not_enough_data")
                return HealthEvaluationResponse(**resp)

            f = build_features(current_data, history)

            if self.use_model:
                X = [[f.get(col, 0) for col in self.features_cols]]
                result = self.model.predict(X)[0]
                status = ["bad", "normal", "good"][result]
            else:
                status = self.evaluate_health_rule_based(f)

            compare = compare_daily(current_data, history)
            resp = self.build_response_msg(status)
            
            return HealthEvaluationResponse(
                status=resp["status"],
                message=resp["message"],
                advice=resp["advice"],
                compare=compare
            )

        except Exception as e:
            logger.error(f"Predict Error: {e}", exc_info=True)
            return HealthEvaluationResponse(
                status="error",
                message="Oops! Có lỗi gì đó rồi",
                advice="Hãy thử load lại để tiếp tục xem chỉ số nhé.",
                compare={}
            )
