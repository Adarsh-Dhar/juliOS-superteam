import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET() {
  // List all agents with required fields
  const agents = await prisma.agent.findMany({
    select: {
      id: true,
      type: true,
      status: true,
      location: true,
      processedCount: true,
      accuracy: true,
      lastActiveAt: true,
    },
    orderBy: { createdAt: 'desc' },
  });

  // Map status based on lastActiveAt
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
  const data = await req.json();
  const { type, name } = data;
  if (!type || !name) {
    return NextResponse.json({ error: 'Missing type or name' }, { status: 400 });
  }
  const agent = await prisma.agent.create({
    data: {
      type,
      name,
      status: 'ACTIVE',
    },
  });
  return NextResponse.json(agent);
} 