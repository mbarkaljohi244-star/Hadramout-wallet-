import { Router, type IRouter } from "express";
import healthRouter from "./health";
import transfersRouter from "./transfers";
import usersRouter from "./users";
import kycRouter from "./kyc";

const router: IRouter = Router();

router.use(healthRouter);
router.use(usersRouter);
router.use(transfersRouter);

// ربط kycRouter ببادئة /kyc بشكل صريح
router.use("/kyc", kycRouter);

export default router;
