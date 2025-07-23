import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export const dynamic = "force-dynamic";

export async function GET() {
  // List all CRAWLER agents with required fields
  const agents = await prisma.agent.findMany({
    where: { type: 'CRAWLER' },
    select: {
      id: true,
      name: true,
      type: true,
      status: true,
      processedCount: true,
      accuracy: true,
      lastActiveAt: true,
    },
    orderBy: { createdAt: 'desc' },
  });

  // Map status based on lastActiveAt (active if within last 5 min)
  const now = Date.now();
  const mappedAgents = agents.map(agent => ({
    ...agent,
    status:
      agent.lastActiveAt && new Date(agent.lastActiveAt).getTime() > now - 5 * 60 * 1000
        ? 'ACTIVE'
        : 'OFFLINE',
  }));

  return NextResponse.json(mappedAgents);
}

export async function POST(req: NextRequest) {
  const body = await req.json();
  if (!body.name || !body.type) {
    return NextResponse.json({ error: 'Missing name or type' }, { status: 400 });
  }
  const agent = await prisma.agent.create({
    data: {
      name: body.name,
      type: body.type,
      status: 'ACTIVE',
      processedCount: 0,
      accuracy: 100,
      lastActiveAt: new Date(),
    },
    select: {
      id: true,
      name: true,
      type: true,
      status: true,
      processedCount: true,
      accuracy: true,
      lastActiveAt: true,
    },
  });
  return NextResponse.json(agent, { status: 201 });
} 