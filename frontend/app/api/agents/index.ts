import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET() {
  // List all active agents
  const agents = await prisma.agent.findMany({
    where: { status: 'ACTIVE' },
    orderBy: { createdAt: 'desc' },
  });
  return NextResponse.json(agents);
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