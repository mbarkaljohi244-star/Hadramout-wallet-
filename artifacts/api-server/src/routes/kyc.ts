import { Router, Request, Response } from "express";

const kycRouter = Router();

// دالة التحقق من التوكن (JWT Bearer Token)
function getBearerToken(authHeader?: string): string | null {
  if (!authHeader || !authHeader.startsWith("Bearer ")) return null;
  return authHeader.split(" ")[1];
}

function verifyAccessToken(token: string): any | null {
  try {
    // يمكن إضافة فحص JWT هنا أو التحقق المباشر
    return { valid: true };
  } catch (error) {
    return null;
  }
}

// 1. مسار تقديم طلب التوثيق (Submit KYC)
kycRouter.post("/submit", async (req: Request, res: Response) => {
  try {
    const authHeader = req.headers.authorization;
    const token = getBearerToken(authHeader);

    if (!token) {
      return res.status(401).json({ success: false, message: "غير مصرح" });
    }

    const payload = verifyAccessToken(token);
    if (!payload) {
      return res.status(401).json({ success: false, message: "رمز الجلسة غير صالح" });
    }

    const { fullName, nationality, idType, idNumber, expiryDate, address, incomeSource } = req.body;

    // إرجاع نجاح عملية التقديم
    return res.status(200).json({
      success: true,
      message: "تم تقديم طلب التوثيق بنجاح",
      status: "PENDING",
      data: {
        fullName,
        nationality,
        idType,
        idNumber,
        expiryDate,
        address,
        incomeSource
      }
    });
  } catch (error) {
    console.error("KYC Submission Error:", error);
    return res.status(500).json({
      success: false,
      message: "حدث خطأ أثناء تقديم طلب التوثيق"
    });
  }
});

// 2. مسار فحص حالة التوثيق (Get KYC Status)
kycRouter.get("/status", async (req: Request, res: Response) => {
  try {
    const authHeader = req.headers.authorization;
    const token = getBearerToken(authHeader);

    if (!token) {
      return res.status(401).json({ success: false, message: "غير مصرح" });
    }

    const payload = verifyAccessToken(token);
    if (!payload) {
      return res.status(401).json({ success: false, message: "رمز الجلسة غير صالح" });
    }

    return res.status(200).json({
      status: "PENDING",
      rejectionReason: null
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: "حدث خطأ أثناء التعرف على حالة التوثيق"
    });
  }
});

export default kycRouter;
