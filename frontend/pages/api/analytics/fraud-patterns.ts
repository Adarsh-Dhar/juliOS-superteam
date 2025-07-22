import { NextApiRequest, NextApiResponse } from 'next';
import { prisma } from '@/lib/prisma';

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  try {
    const patterns = await prisma.verification.groupBy({
      by: ['fraudType'],
      where: {
        NOT: { fraudType: null },
        status: 'FAKE'
      },
      _count: { _all: true },
      _avg: { confidence: true }
    });

    const result = patterns.map(pattern => ({
      id: pattern.fraudType!,
      type: pattern.fraudType!,
      count: pattern._count._all,
      confidence: pattern._avg.confidence || 0,
      severity: pattern._count._all > 10 ? 'high' : pattern._count._all > 5 ? 'medium' : 'low',
      relatedPatterns: patterns
        .filter(p => p.fraudType !== pattern.fraudType)
        .map(p => p.fraudType!)
        .slice(0, 3)
    }));

    res.status(200).json({ patterns: result });
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
} 