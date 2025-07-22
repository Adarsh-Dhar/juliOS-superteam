import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET(req: NextRequest, { params }: { params: { id: string } }) {
  const agent = await prisma.agent.findUnique({ where: { id: params.id } });
  if (!agent) return NextResponse.json({ error: 'Not found' }, { status: 404 });
  return NextResponse.json(agent);
}

export async function PUT(req: NextRequest, { params }: { params: { id: string } }) {
  const data = await req.json();
  const { status, processedCount } = data;
  if (!status) {
    return NextResponse.json({ error: 'Missing status' }, { status: 400 });
  }
  const agent = await prisma.agent.update({
    where: { id: params.id },
    data: {
      status,
      ...(processedCount !== undefined ? { processedCount } : {}),
      lastActiveAt: new Date(),
    },
  });
  return NextResponse.json(agent);
}

export async function DELETE(req: NextRequest, { params }: { params: { id: string } }) {
  await prisma.agent.delete({ where: { id: params.id } });
  return NextResponse.json({ success: true, id: params.id });
}
