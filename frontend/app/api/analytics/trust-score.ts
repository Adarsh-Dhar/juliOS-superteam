import { NextApiRequest, NextApiResponse } from 'next';
import { prisma } from '@/lib/prisma';

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  try {
    const authenticVerifications = await prisma.verification.findMany({
      where: { status: 'AUTHENTIC' },
      select: { confidence: true }
    });

    const trustScore = authenticVerifications.length > 0
      ? Math.round(authenticVerifications.reduce((sum, v) => sum + v.confidence, 0) / authenticVerifications.length)
      : 0;

    res.status(200).json({ score: trustScore });
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
} 