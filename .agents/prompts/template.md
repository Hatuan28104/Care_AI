[AGENT: <pm | dev | reviewe>]

---

## 🧠 TASK
Mô tả rõ nhiệm vụ cần làm

---

## 📥 INPUT
{{input}}
{{plan}}
{{code}}
{{bug}}

---

## 📚 CONTEXT
- ../context.md (nếu có)

---

## ⚙️ RULES (BẮT BUỘC)
- Follow đúng role của agent
- Không tự suy diễn
- Không bỏ sót requirement
- Output đúng format

---

## 🛠 SKILLS (optional)
- validation
- architecture
- error

---

## 🎯 YÊU CẦU
- Viết rõ từng requirement cụ thể
- Không mơ hồ
- Nếu thiếu dữ liệu → không tự đoán

---

## 📤 OUTPUT (BẮT BUỘC JSON)

{
  // tùy agent
}

---

## ⚠️ OUTPUT RULE
- JSON ONLY
- Không giải thích ngoài JSON
- Không thêm text