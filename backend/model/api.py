# -----------------------------
# 🔹 Import Python libraries
# -----------------------------
from flask import Flask, request, jsonify         # สำหรับสร้าง web API
from flask_cors import CORS                       # เพื่อเปิด CORS ให้สามารถเรียกจาก front-end ได้
from pydantic import BaseModel, Field, ValidationError  # สำหรับ validate ข้อมูล input
from werkzeug.exceptions import BadRequest        # สำหรับจัดการข้อผิดพลาดของ request
import joblib                                     # สำหรับโหลดโมเดลที่ train ไว้
import numpy as np                                # สำหรับจัดการข้อมูลในรูปแบบ array
from datetime import date

# -----------------------------
# 🔹 Configuration
# -----------------------------
app = Flask(__name__) # สร้าง Flask app เพื่อใช้สร้าง API
CORS(app)  # เปิดใช้งาน CORS เพื่อให้ front-end เรียก API ได้
MODEL_PATH = "LBMA-SILVER-model.pkl" # ที่เก็บโมเดลที่ train ไว้
 
# -----------------------------
# 🔹 Load ML model at startup
# -----------------------------
try:
    model = joblib.load(MODEL_PATH)   # โหลดโมเดลที่ train ไว้แล้ว
except Exception as e:
    raise RuntimeError(f"Failed to load model: {e}")  # ถ้าโหลดไม่สำเร็จ ให้หยุดโปรแกรมพร้อมข้อความ
 
# -----------------------------
# 🔹 Define input schema to validate inputs
# -----------------------------
class SilverFeatures(BaseModel):
    silver_date: date = Field(..., description="วันเดือนปี (YYYY-MM-DD)")

@app.route("/api/silver", methods=["POST"])
def predict_silver_price():
    try:
        # รับข้อมูล JSON จาก client
        data = request.get_json()

        # ตรวจสอบและแปลงข้อมูลด้วย Pydantic
        features = SilverFeatures(**data)

        # แปลงวันเดือนปีเป็น year และ month
        year = features.silver_date.year
        month = features.silver_date.month
        x = np.array([[year, month]])  # สร้าง array สำหรับโมเดล

        # ทำนายราคาด้วยโมเดลที่โหลดมา
        prediction = model.predict(x)

        # ส่งผลลัพธ์กลับในรูป JSON
        return jsonify({
            "status": True,
            "price": np.round(float(prediction[0]), 2),
            "currency": "USD/Oz"  # ปรับหน่วยให้ตรงกับข้อมูลเทรน
        })

    except ValidationError as ve:
        # จัดการข้อผิดพลาดกรณี input ไม่ถูกต้อง
        errors = {}
        for error in ve.errors():
            field = error['loc'][0]
            msg = error['msg']
            errors.setdefault(field, []).append(msg)
        return jsonify({"status": False, "detail": errors}), 400
    except BadRequest as e:
        # จัดการข้อผิดพลาดกรณี input ไม่ถูกต้อง
        return jsonify({
            "status": False,
            "error": "Invalid JSON format",
            "detail": str(e)
        }), 400
    except Exception as e:
        # จัดการข้อผิดพลาดอื่น ๆ
        return jsonify({"status": False, "error": str(e)}), 500
 
# -----------------------------
# 🔹 Run API server
# -----------------------------
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)