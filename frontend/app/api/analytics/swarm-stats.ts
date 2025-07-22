import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET() {
  try {
    // Get all agents
    const agents = await prisma.agent.findMany();
    const now = Date.now();
    const activeAgents = agents.filter(
      a =>
        a.lastActiveAt &&
        new Date(a.lastActiveAt).getTime() > now - 5 * 60 * 1000
    ).length;

    // Verifications today
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const verifications = await prisma.verification.count({
      where: { createdAt: { gte: today } }
    });

    // Trust score: average confidence of AUTHENTIC verifications today
    const authenticVerifications = await prisma.verification.findMany({
      where: { status: 'AUTHENTIC', createdAt: { gte: today } },
      select: { confidence: true }
    });

    const trustScore =
      authenticVerifications.length > 0
        ? Math.round(
            authenticVerifications.reduce((sum, v) => sum + v.confidence, 0) /
              authenticVerifications.length
          )
        : 0;

    // Network health: % of active agents
    const networkHealth =
      agents.length > 0
        ? Math.round((activeAgents / agents.length) * 100)
        : 0;

    return NextResponse.json({
      activeAgents,
      verifiedToday: verifications,
      trustScore,
      networkHealth
    });
  } catch (error) {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
} 