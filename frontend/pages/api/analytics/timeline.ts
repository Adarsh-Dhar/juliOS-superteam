import { NextApiRequest, NextApiResponse } from 'next';
import { prisma } from '@/lib/prisma';

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  try {
    const now = new Date();
    const intervals = 6;
    const intervalHours = 4;
    const timelineData = [];

    for (let i = intervals - 1; i >= 0; i--) {
      const endTime = new Date(now);
      endTime.setHours(now.getHours() - i * intervalHours);
      const startTime = new Date(endTime);
      startTime.setHours(endTime.getHours() - intervalHours);

      const timeLabel = endTime.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

      const [authentic, suspicious, fake] = await Promise.all([
        prisma.verification.count({
          where: { status: 'AUTHENTIC', createdAt: { gte: startTime, lt: endTime } }
        }),
        prisma.verification.count({
          where: { status: 'PENDING', createdAt: { gte: startTime, lt: endTime } }
        }),
        prisma.verification.count({
          where: { status: 'FAKE', createdAt: { gte: startTime, lt: endTime } }
        })
      ]);

      timelineData.push({ time: timeLabel, authentic, suspicious, fake });
    }

    res.status(200).json(timelineData);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
} 