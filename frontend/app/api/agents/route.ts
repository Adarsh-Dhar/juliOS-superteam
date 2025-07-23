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

  // Proxy the request to the Julia backend
  try {
    const juliaRes = await fetch('http://localhost:8052/api/v1/agents', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });
    const juliaData = await juliaRes.json();
    return NextResponse.json(juliaData, { status: juliaRes.status });
  } catch (error) {
    return NextResponse.json({ error: 'Failed to create agent in Julia backend', details: error?.toString() }, { status: 500 });
  }
} 