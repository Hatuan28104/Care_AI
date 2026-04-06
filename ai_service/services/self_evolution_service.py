import logging
from core.schema import HealthDataInput, HealthEvaluationResponse
from core.utils import build_features, compare_daily

logger = logging.getLogger(__name__)

class SelfEvolutionService:
    def __init__(self, model_bundle: dict = None):
        self.model = model_bundle.get("model") if model_bundle else None
        self.features_cols = model_bundle.get("features") if model_bundle else None
        self.use_model = self.model is not None and self.features_cols is not None

    def rule_guardrail(self, current: dict) -> dict:
        spo2 = current.get("spo2", 100)
        hr = current.get("heart_rate", 70)
        sleep = current.get("sleep_hours", 8)

        reasons = []
        if spo2 < 92:
            reasons.append("SpO2 thấp")
        if hr > 110:
            reasons.append("Nhịp tim cao")
        if sleep < 4:
            reasons.append("Thiếu ngủ nghiêm trọng")

        if reasons:
            return {
                "override": True,
                "status": "xấu",
                "reason": "; ".join(reasons),
                "reasons": reasons
            }
        return {"override": False, "reasons": []}

    def evaluate_metrics(self, f: dict) -> dict:
        return {
            "steps": f.get("steps_diff", 0),
            "sleep_hours": f.get("sleep_diff", 0),
            "heart_rate": f.get("hr_diff", 0),
            "spo2": f.get("spo2_diff", 0),
            "hrv": f.get("hrv_diff", 0),
            "distance": f.get("distance_diff", 0)
        }

    def validate_input_quality(self, current: dict) -> dict:
        flags = []
        warnings = []

        spo2 = current.get("spo2", 0)
        hr = current.get("heart_rate", 0)

        if spo2 and spo2 < 70:
            flags.append("sensor_error_or_critical")
            warnings.append("SpO2 quá thấp bất thường, cần kiểm tra thiết bị hoặc đo lại ngay")

        if hr and hr > 200:
            flags.append("invalid_data")
            warnings.append("Nhịp tim vượt ngưỡng dữ liệu hợp lệ, cần kiểm tra thiết bị")

        return {
            "has_anomaly": len(flags) > 0,
            "flags": flags,
            "warnings": warnings
        }

    def build_metric_message(self, status: str, diffs: dict, override_info: dict) -> dict:
        PRIORITY = ["spo2", "heart_rate", "sleep_hours", "steps", "hrv", "distance"]

        METRIC_MESSAGES = {
            "steps": {
                "good": {
                    "mild": ["Bạn vận động khá tốt hôm nay", "Lượng bước chân tăng nhẹ", "Hoạt động thể chất ổn"],
                    "moderate": ["Bạn vận động tốt hôm nay", "Lượng bước chân tăng đáng kể", "Hoạt động thể chất tích cực"],
                    "strong": ["Bạn vận động rất tốt!", "Lượng bước chân tăng vượt trội", "Hoạt động thể chất xuất sắc"]
                },
                "bad": {
                    "mild": ["Lượng vận động hôm nay hơi ít", "Bạn có thể đi bộ thêm chút", "Hoạt động thể chất chưa đủ"],
                    "moderate": ["Lượng vận động hôm nay còn thấp", "Cần tăng cường đi bộ hơn", "Hoạt động thể chất cần cải thiện"],
                    "strong": ["Lượng vận động quá thấp!", "Bạn cần đi bộ nhiều hơn ngay", "Hoạt động thể chất rất kém"]
                }
            },
            "sleep_hours": {
                "good": {
                    "mild": ["Giấc ngủ khá hơn hôm nay", "Bạn ngủ thêm chút", "Chất lượng giấc ngủ ổn"],
                    "moderate": ["Giấc ngủ của bạn đã cải thiện", "Bạn ngủ nhiều hơn hôm nay", "Chất lượng giấc ngủ tốt hơn"],
                    "strong": ["Giấc ngủ tuyệt vời!", "Bạn ngủ rất nhiều hôm nay", "Chất lượng giấc ngủ xuất sắc"]
                },
                "bad": {
                    "mild": ["Bạn ngủ hơi ít hôm nay", "Thời gian ngủ chưa đủ", "Giấc ngủ cần cải thiện chút"],
                    "moderate": ["Bạn ngủ chưa đủ giấc", "Thời gian ngủ còn ít", "Giấc ngủ cần được cải thiện"],
                    "strong": ["Bạn ngủ quá ít!", "Thời gian ngủ rất ít", "Giấc ngủ rất kém"]
                }
            },
            "heart_rate": {
                "good": {
                    "mild": ["Nhịp tim khá hơn chút", "Nhịp tim giảm nhẹ", "Tim mạch ổn"],
                    "moderate": ["Nhịp tim đang ổn định hơn", "Nhịp tim giảm so với trước", "Tim mạch hoạt động tốt"],
                    "strong": ["Nhịp tim rất tốt!", "Nhịp tim giảm đáng kể", "Tim mạch hoạt động xuất sắc"]
                },
                "bad": {
                    "mild": ["Nhịp tim hơi cao", "Tim đập nhanh chút", "Nhịp tim cần theo dõi"],
                    "moderate": ["Nhịp tim có dấu hiệu cao", "Tim đập nhanh hơn bình thường", "Nhịp tim cần chú ý"],
                    "strong": ["Nhịp tim quá cao!", "Tim đập rất nhanh", "Nhịp tim nguy hiểm"]
                }
            },
            "spo2": {
                "good": {
                    "mild": ["Nồng độ oxy khá hơn", "Nồng độ oxy trong máu ổn định", "Chỉ số oxy máu cải thiện chút"],
                    "moderate": ["Nồng độ oxy máu tốt", "Oxy trong máu ổn định", "Chỉ số oxy máu cải thiện"],
                    "strong": ["Nồng độ oxy tuyệt vời!", "Oxy trong máu rất tốt", "Chỉ số oxy máu xuất sắc"]
                },
                "bad": {
                    "mild": ["Nồng độ oxy hơi thấp", "Oxy trong máu giảm chút", "Cần chú ý đến nồng độ oxy"],
                    "moderate": ["Nồng độ oxy máu thấp", "Oxy trong máu giảm", "Cần chú ý đến nồng độ oxy"],
                    "strong": ["Nồng độ oxy quá thấp!", "Oxy trong máu rất thấp", "Nồng độ oxy nguy hiểm"]
                }
            },
            "hrv": {
                "good": {
                    "mild": ["Khả năng phục hồi khá hơn", "Chỉ số HRV tăng nhẹ", "Sức khỏe tinh thần ổn"],
                    "moderate": ["Khả năng phục hồi tốt", "Chỉ số HRV tăng", "Sức khỏe tinh thần ổn định"],
                    "strong": ["Khả năng phục hồi tuyệt vời!", "Chỉ số HRV tăng mạnh", "Sức khỏe tinh thần xuất sắc"]
                },
                "bad": {
                    "mild": ["Khả năng phục hồi hơi kém", "HRV giảm chút", "Cần thư giãn thêm"],
                    "moderate": ["Khả năng phục hồi kém", "HRV giảm", "Cần thư giãn nhiều hơn"],
                    "strong": ["Khả năng phục hồi rất kém!", "HRV giảm mạnh", "Cần thư giãn ngay"]
                }
            },
            "distance": {
                "good": {
                    "mild": ["Quãng đường di chuyển tăng chút", "Bạn di chuyển khá hơn", "Hoạt động ngoài trời ổn"],
                    "moderate": ["Quãng đường di chuyển tăng", "Bạn di chuyển nhiều hơn", "Hoạt động ngoài trời tốt"],
                    "strong": ["Quãng đường di chuyển tăng nhiều!", "Bạn di chuyển rất nhiều", "Hoạt động ngoài trời xuất sắc"]
                },
                "bad": {
                    "mild": ["Quãng đường di chuyển hơi ít", "Cần tăng cường vận động ngoài trời chút", "Di chuyển chưa đủ"],
                    "moderate": ["Quãng đường di chuyển ít", "Cần tăng cường vận động ngoài trời", "Di chuyển cần cải thiện"],
                    "strong": ["Quãng đường di chuyển quá ít!", "Cần đi ra ngoài nhiều hơn ngay", "Di chuyển rất kém"]
                }
            }
        }

        METRIC_ADVICE = {
            "spo2": {
                "bad": {
                    "mild": "Hãy thử hít thở sâu và tránh môi trường thiếu oxy.",
                    "moderate": "Cần chú ý đến nồng độ oxy, tránh khói bụi và tập thở sâu.",
                    "strong": "Hãy kiểm tra sức khỏe và liên hệ bác sĩ nếu cần. Tránh môi trường thiếu oxy."
                }
            },
            "heart_rate": {
                "bad": {
                    "mild": "Thử thư giãn chút và theo dõi nhịp tim.",
                    "moderate": "Hạn chế stress, tập thở sâu và theo dõi nhịp tim thường xuyên.",
                    "strong": "Nhịp tim cao nguy hiểm! Hãy nghỉ ngơi và liên hệ bác sĩ nếu cần."
                }
            },
            "sleep_hours": {
                "bad": {
                    "mild": "Cố gắng ngủ sớm hơn chút.",
                    "moderate": "Cố gắng ngủ sớm hơn, tránh thiết bị điện tử và duy trì lịch ngủ đều đặn.",
                    "strong": "Thiếu ngủ nghiêm trọng! Hãy nghỉ ngơi đầy đủ và liên hệ bác sĩ nếu cần."
                }
            },
            "steps": {
                "bad": {
                    "mild": "Thử đi bộ thêm chút mỗi ngày.",
                    "moderate": "Hãy tăng cường đi bộ hoặc tập thể dục nhẹ nhàng mỗi ngày.",
                    "strong": "Thiếu vận động nghiêm trọng! Cần đi bộ nhiều hơn ngay để cải thiện sức khỏe."
                }
            },
            "hrv": {
                "bad": {
                    "mild": "Thử thư giãn thêm chút.",
                    "moderate": "Tăng cường thư giãn, yoga hoặc thiền để cải thiện sức khỏe tinh thần.",
                    "strong": "Sức khỏe tinh thần kém! Cần nghỉ ngơi và tìm sự hỗ trợ chuyên môn."
                }
            },
            "distance": {
                "bad": {
                    "mild": "Thử đi dạo ngoài trời thêm chút.",
                    "moderate": "Thử đi dạo ngoài trời hoặc tham gia hoạt động thể thao nhẹ.",
                    "strong": "Thiếu hoạt động ngoài trời nghiêm trọng! Cần ra ngoài nhiều hơn để cải thiện sức khỏe."
                }
            }
        }


        current_metrics = override_info.get("current_metrics", {}) if isinstance(override_info, dict) else {}

        def get_metric_status_and_intensity(metric: str, diff: float, current_value: float = None):
            if metric == "steps":
                if diff > 1000: return "good", "strong"
                elif diff > 500: return "good", "moderate"
                elif diff > 200: return "good", "mild"
                elif diff < -1000: return "bad", "strong"
                elif diff < -500: return "bad", "moderate"
                elif diff < -200: return "bad", "mild"
            elif metric == "sleep_hours":
                if diff > 2: return "good", "strong"
                elif diff > 1: return "good", "moderate"
                elif diff > 0.5: return "good", "mild"
                elif diff < -2: return "bad", "strong"
                elif diff < -1: return "bad", "moderate"
                elif diff < -0.5: return "bad", "mild"
            elif metric == "heart_rate":
                if diff < -10: return "good", "strong"
                elif diff < -5: return "good", "moderate"
                elif diff < -2: return "good", "mild"
                elif diff > 10: return "bad", "strong"
                elif diff > 5: return "bad", "moderate"
                elif diff > 2: return "bad", "mild"
            elif metric == "spo2":
                if current_value is None:
                    return "neutral", None

                if current_value < 90:
                    return "bad", "strong"
                if diff > 5: return "good", "strong"
                elif diff > 2: return "good", "moderate"
                elif diff > 1: return "good", "mild"
                elif diff < -5: return "bad", "strong"
                elif diff < -2: return "bad", "moderate"
                elif diff < -1: return "bad", "mild"
            elif metric == "hrv":
                if diff > 10: return "good", "strong"
                elif diff > 5: return "good", "moderate"
                elif diff > 2: return "good", "mild"
                elif diff < -10: return "bad", "strong"
                elif diff < -5: return "bad", "moderate"
                elif diff < -2: return "bad", "mild"
            elif metric == "distance":
                if diff > 1.0: return "good", "strong"
                elif diff > 0.5: return "good", "moderate"
                elif diff > 0.2: return "good", "mild"
                elif diff < -1.0: return "bad", "strong"
                elif diff < -0.5: return "bad", "moderate"
                elif diff < -0.2: return "bad", "mild"
            return "neutral", None

        metric_data = {}
        for metric, diff in diffs.items():
            metric_status, intensity = get_metric_status_and_intensity(metric, diff, current_metrics.get(metric))
            if metric_status != "neutral":
                metric_data[metric] = {"status": metric_status, "intensity": intensity, "priority": PRIORITY.index(metric)}

        good_metrics = sorted(
            [m for m, d in metric_data.items() if d["status"] == "good"],
            key=lambda x: metric_data[x]["priority"]
        )
        bad_metrics = sorted(
            [m for m, d in metric_data.items() if d["status"] == "bad"],
            key=lambda x: metric_data[x]["priority"]
        )

        if override_info.get("override") and "spo2" in bad_metrics:
            bad_metrics.remove("spo2")
            bad_metrics.insert(0, "spo2")
        if override_info.get("override"):
            good_metrics = []
        message_parts = []

        if good_metrics:
            metric = good_metrics[0]
            intensity = metric_data[metric]["intensity"]
            variants = METRIC_MESSAGES[metric]["good"][intensity]
            message_parts.append(variants[0])

        if bad_metrics:
            metric = bad_metrics[0]
            intensity = metric_data[metric]["intensity"]
            variants = METRIC_MESSAGES[metric]["bad"][intensity]
            bad_msg = variants[0]
            if message_parts:
                connector = "tuy nhiên"
                message_parts.append(f"{connector} {bad_msg.lower()}")
            else:
                message_parts.append(bad_msg)

        if not message_parts:
            message_parts.append("Các chỉ số sức khỏe của bạn đang duy trì ổn định")

        if len(message_parts) == 2:
            message = f"{message_parts[0]}, {message_parts[1]}"
        else:
            message = message_parts[0]

        advice_parts = []
        if bad_metrics:
            for metric in bad_metrics[:2]: 
                intensity = metric_data[metric]["intensity"]
                if metric in METRIC_ADVICE and "bad" in METRIC_ADVICE[metric]:
                    advice_parts.append(METRIC_ADVICE[metric]["bad"][intensity])

            advice = " ".join(advice_parts) if advice_parts else "Hãy chú ý đến các chỉ số sức khỏe và duy trì lối sống lành mạnh."
        elif good_metrics:
            good_metric = good_metrics[0]
            advice_map = {
                "steps": "Tiếp tục duy trì thói quen vận động tích cực.",
                "sleep_hours": "Giữ vững thói quen ngủ chất lượng.",
                "heart_rate": "Tiếp tục theo dõi và duy trì nhịp tim khỏe mạnh.",
                "spo2": "Tiếp tục duy trì lối sống lành mạnh để giữ nồng độ oxy tốt.",
                "hrv": "Tiếp tục chăm sóc sức khỏe tinh thần.",
                "distance": "Tiếp tục duy trì hoạt động ngoài trời."
            }
            advice = advice_map.get(good_metric, "Tiếp tục duy trì thói quen lành mạnh.")
        else:
            advice = "Tiếp tục duy trì thói quen lành mạnh và theo dõi sức khỏe thường xuyên."

        if override_info.get("override"):
            readable_warning = override_info.get("reason", "một số chỉ số đang ở mức nguy hiểm")
            message = f"{message}, cần chú ý vì {readable_warning.lower()}"
            advice = f"{advice} Nếu cảm thấy bất thường, hãy kiểm tra sức khỏe ngay."

        return {"status": status, "message": message, "advice": advice}

    def predict(self, data: HealthDataInput) -> HealthEvaluationResponse:
        try:
            current_data = data.current_metrics.model_dump() if hasattr(data.current_metrics, "model_dump") else data.current_metrics.dict()
            history = data.history or []

            if len(history) < 1:
                return HealthEvaluationResponse(
                    status="error",
                    message="Chưa có đủ dữ liệu để phân tích",
                    advice="Hãy đeo thiết bị thêm vài ngày để hệ thống học thói quen của bạn nhé.",
                    compare={}
                )

            f = build_features(current_data, history)

            data_quality = self.validate_input_quality(current_data)

            if self.use_model:
                X = [[f.get(col, 0) for col in self.features_cols]]
                result = self.model.predict(X)[0]
                status = ["xấu", "bình thường", "tốt"][result]
            else:
                return HealthEvaluationResponse(
                    status="không xác định",
                    message="Không đủ dữ liệu để đánh giá chính xác",
                    advice="Hãy kiểm tra thiết bị hoặc thử lại sau",
                    compare=compare_daily(current_data, history),
                )

            override_info = self.rule_guardrail(current_data)
            override_info["current_metrics"] = current_data
            override_info["data_quality"] = data_quality
            if override_info["override"]:
                status = override_info["status"]

            metrics_info = self.evaluate_metrics(f)

            resp = self.build_metric_message(status, metrics_info, override_info)

            compare = compare_daily(current_data, history)

            

            if data_quality["has_anomaly"]:
                resp["message"] = f"{resp['message']}. Cảnh báo dữ liệu: {'; '.join(data_quality['warnings'])}."
                resp["advice"] = f"{resp['advice']} Vui lòng đo lại để xác nhận chỉ số."

            return HealthEvaluationResponse(
                status=resp["status"],
                message=resp["message"],
                advice=resp["advice"],
                compare=compare,
            )

        except Exception as e:
            logger.error(f"Predict Error: {e}", exc_info=True)
            return HealthEvaluationResponse(
                status="error",
                message="Oops! Có lỗi gì đó rồi",
                advice="Hãy thử load lại để tiếp tục xem chỉ số nhé.",
                compare={}
            )
