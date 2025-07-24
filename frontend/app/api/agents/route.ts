import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export const dynamic = "force-dynamic";

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

  // Map status based on backend status
  const mappedAgents = agents.map(agent => ({
    ...agent,
    status: agent.status === 'RUNNING' ? 'ACTIVE' : 'OFFLINE',
  }));

  return NextResponse.json(mappedAgents);
}

export async function POST(req: NextRequest) {
  const data = await req.json();
  const { type, name, status } = data;
  if (!type || !name) {
    return NextResponse.json({ error: 'Missing type or name' }, { status: 400 });
  }
  // Proxy the request to the Julia backend
  try {
    const juliaRes = await fetch('http://localhost:8052/api/v1/agents', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        name,
        type,
        status: status || 'ACTIVE',
      }),
    });
    const juliaData = await juliaRes.json();
    return NextResponse.json(juliaData, { status: juliaRes.status });
  } catch (error) {
    return NextResponse.json({ error: 'Failed to create agent in Julia backend', details: error?.toString() }, { status: 500 });
  }
} 