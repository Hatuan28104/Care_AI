export const HEALTH_ALERT_RULES = {
    HR: {
        name: "Nhịp tim",
        unit: "lần/phút",
        guardianLevel: 3,
        check(value) {
            if (value >= 130 || value < 40) return { level: 3, message: "Nhịp tim ở mức nguy hiểm" };
            if (value >= 110 || value < 50) return { level: 2, message: "Nhịp tim bất thường" };
            if (value >= 100 || value < 60) return { level: 1, message: "Nhịp tim hơi bất thường" };
            return null;
        },
    },

    BLOOD_PRESSURE: {
        name: "Huyết áp",
        unit: "mmHg",
        guardianLevel: 3,
        check(value) {
            if (value >= 180) return { level: 3, message: "Huyết áp ở mức nguy hiểm" };
            if (value >= 140) return { level: 2, message: "Huyết áp cao" };
            if (value >= 130) return { level: 1, message: "Huyết áp hơi cao" };
            if (value < 90) return { level: 2, message: "Huyết áp thấp" };
            return null;
        },
    },

    STEPS: {
        name: "Số bước chân",
        unit: "steps",
        guardianLevel: 99,
        check(value) {
            if (value < 1000) return { level: 2, message: "Số bước chân hôm nay rất thấp" };
            if (value < 3000) return { level: 1, message: "Số bước chân hôm nay thấp" };
            return null;
        },
    },

    CALORIES: {
        name: "Calo tiêu thụ",
        unit: "kcal",
        guardianLevel: 99,
        check(value) {
            if (value < 100) return { level: 2, message: "Calo tiêu thụ hôm nay rất thấp" };
            if (value < 300) return { level: 1, message: "Calo tiêu thụ hôm nay thấp" };
            return null;
        },
    },

    RESPIRATORY_RATE: {
        name: "Nhịp thở",
        unit: "lần/phút",
        guardianLevel: 3,
        check(value) {
            if (value >= 30 || value < 8) return { level: 3, message: "Nhịp thở nguy hiểm" };
            if (value >= 22 || value < 10) return { level: 2, message: "Nhịp thở bất thường" };
            if (value >= 19 || value < 12) return { level: 1, message: "Nhịp thở hơi bất thường" };
            return null;
        },
    },

    HRV: {
        name: "HRV",
        unit: "ms",
        guardianLevel: 99,
        check(value) {
            if (value < 15) return { level: 2, message: "HRV rất thấp, cơ thể có thể đang căng thẳng hoặc hồi phục kém" };
            if (value < 25) return { level: 1, message: "HRV thấp hơn mức khuyến nghị" };
            return null;
        },
    },

    BLOOD_GLUCOSE: {
        name: "Đường huyết",
        unit: "mg/dL",
        guardianLevel: 3,
        check(value) {
            if (value >= 250 || value < 70) return { level: 3, message: "Đường huyết nguy hiểm" };
            if (value >= 126 || value < 80) return { level: 2, message: "Đường huyết bất thường" };
            if (value >= 100) return { level: 1, message: "Đường huyết hơi cao" };
            return null;
        },
    },

    BODY_FAT: {
        name: "Mỡ cơ thể",
        unit: "%",
        guardianLevel: 99,
        check(value) {
            if (value >= 35) return { level: 2, message: "Tỷ lệ mỡ cơ thể cao" };
            if (value >= 28) return { level: 1, message: "Tỷ lệ mỡ cơ thể hơi cao" };
            if (value < 5) return { level: 2, message: "Tỷ lệ mỡ cơ thể quá thấp" };
            return null;
        },
    },

    MUSCLE_MASS: {
        name: "Khối lượng cơ",
        unit: "kg",
        guardianLevel: 99,
        check(value) {
            if (value <= 0) return null;
            return null;
        },
    },

    BODY_WATER: {
        name: "Nước cơ thể",
        unit: "%",
        guardianLevel: 99,
        check(value) {
            if (value < 40) return { level: 3, message: "Tỷ lệ nước cơ thể rất thấp" };
            if (value < 45) return { level: 2, message: "Tỷ lệ nước cơ thể thấp" };
            if (value < 50) return { level: 1, message: "Tỷ lệ nước cơ thể hơi thấp" };
            return null;
        },
    },

    VO2_MAX: {
        name: "Lượng oxy tiêu thụ tối đa",
        unit: "ml/kg/min",
        guardianLevel: 99,
        check(value) {
            if (value < 20) return { level: 2, message: "VO2 Max rất thấp" };
            if (value < 30) return { level: 1, message: "VO2 Max thấp" };
            return null;
        },
    },

    STRESS: {
        name: "Mức độ căng thẳng",
        unit: "%",
        guardianLevel: 3,
        check(value) {
            if (value >= 90) return { level: 3, message: "Mức căng thẳng rất cao" };
            if (value >= 75) return { level: 2, message: "Mức căng thẳng cao" };
            if (value >= 60) return { level: 1, message: "Mức căng thẳng tăng" };
            return null;
        },
    },

    RECOVERY: {
        name: "Chỉ số hồi phục",
        unit: "%",
        guardianLevel: 3,
        check(value) {
            if (value < 20) return { level: 3, message: "Chỉ số hồi phục rất thấp" };
            if (value < 40) return { level: 2, message: "Chỉ số hồi phục thấp" };
            if (value < 60) return { level: 1, message: "Chỉ số hồi phục chưa tốt" };
            return null;
        },
    },

    SPO2: {
        name: "SpO2",
        unit: "%",
        guardianLevel: 3,
        check(value) {
            if (value < 90) return { level: 3, message: "SpO2 thấp nguy hiểm" };
            if (value <= 93) return { level: 2, message: "SpO2 thấp" };
            if (value === 94) return { level: 1, message: "SpO2 hơi thấp" };
            return null;
        },
    },

    HYDRATION: {
        name: "Mức hydrat hóa",
        unit: "%",
        guardianLevel: 99,
        check(value) {
            if (value < 40) return { level: 3, message: "Mức hydrat hóa rất thấp" };
            if (value < 50) return { level: 2, message: "Mức hydrat hóa thấp" };
            if (value < 60) return { level: 1, message: "Mức hydrat hóa hơi thấp" };
            return null;
        },
    },

    BODY_TEMP: {
        name: "Nhiệt độ cơ thể",
        unit: "°C",
        guardianLevel: 3,
        check(value) {
            if (value >= 39 || value < 35) return { level: 3, message: "Nhiệt độ cơ thể nguy hiểm" };
            if (value >= 38 || value < 36) return { level: 2, message: "Nhiệt độ cơ thể bất thường" };
            if (value >= 37.5) return { level: 1, message: "Có dấu hiệu sốt nhẹ" };
            return null;
        },
    },

    BMI: {
        name: "Chỉ số BMI",
        unit: "kg/m²",
        guardianLevel: 99,
        check(value) {
            if (value >= 35 || value < 16) return { level: 3, message: "BMI ở mức rủi ro cao" };
            if (value >= 30 || value < 17) return { level: 2, message: "BMI bất thường" };
            if (value >= 25 || value < 18.5) return { level: 1, message: "BMI ngoài vùng khuyến nghị" };
            return null;
        },
    },

    DISTANCE: {
        name: "Quãng đường",
        unit: "km",
        guardianLevel: 99,
        check(value) {
            if (value < 0.5) return { level: 2, message: "Quãng đường vận động hôm nay rất thấp" };
            if (value < 1.5) return { level: 1, message: "Quãng đường vận động hôm nay thấp" };
            return null;
        },
    },

    ACTIVE_MINUTES: {
        name: "Thời gian vận động",
        unit: "phút",
        guardianLevel: 99,
        check(value) {
            if (value < 10) return { level: 2, message: "Thời gian vận động hôm nay rất thấp" };
            if (value < 30) return { level: 1, message: "Thời gian vận động hôm nay thấp" };
            return null;
        },
    },

    SLEEP: {
        name: "Thời gian ngủ",
        unit: "giờ",
        guardianLevel: 99,
        check(value) {
            if (value < 4) return { level: 3, message: "Thời gian ngủ quá thấp" };
            if (value < 6 || value > 10) return { level: 2, message: "Thời gian ngủ bất thường" };
            if (value < 7 || value > 9) return { level: 1, message: "Thời gian ngủ chưa tối ưu" };
            return null;
        },
    },

    SLEEP_QUALITY: {
        name: "Chất lượng giấc ngủ",
        unit: "%",
        guardianLevel: 99,
        check(value) {
            if (value < 40) return { level: 3, message: "Chất lượng giấc ngủ rất thấp" };
            if (value < 60) return { level: 2, message: "Chất lượng giấc ngủ thấp" };
            if (value < 75) return { level: 1, message: "Chất lượng giấc ngủ chưa tốt" };
            return null;
        },
    },
};