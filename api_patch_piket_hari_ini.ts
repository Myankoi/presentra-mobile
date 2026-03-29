// =====================================================================
// PASTE THIS INTO presentra-api project
// =====================================================================

// ── 1. Add to src/controllers/jadwal.controller.ts ─────────────────

import { db } from "../db/index.js";
import { jadwalPiket } from "../db/schema.js";
import { eq, and } from "drizzle-orm";
import type { Request, Response, NextFunction } from "express";

export const getCekPiketHariIni = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const userId = (req as any).user.id;

        // Get today's day name in Indonesian
        const hariIni = new Intl.DateTimeFormat('id-ID', { 
            weekday: 'long', 
            timeZone: 'Asia/Jakarta' 
        }).format(new Date()).toLowerCase();

        const result = await db
            .select()
            .from(jadwalPiket)
            .where(
                and(
                    eq(jadwalPiket.guruId, userId),
                    eq(jadwalPiket.hari, hariIni as any)
                )
            );

        const isPiket = result.length > 0;

        res.status(200).json({
            success: true,
            isPiket,
            data: isPiket ? {
                id: result[0].id,
                hari: result[0].hari,
                keterangan: result[0].keterangan,
            } : null
        });
    } catch (error) {
        next(error);
    }
};


// ── 2. Add to src/routes/jadwal.routes.ts ──────────────────────────

// Add import:
// import { getJadwalGuru, getJadwalByKelas, getCekPiketHariIni } from "../controllers/jadwal.controller.js";

// Add route:
// router.get("/piket-hari-ini", authMiddleware, roleMiddleware(["guru"]), getCekPiketHariIni);
