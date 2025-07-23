import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export const dynamic = "force-dynamic";

export async function DELETE(_req: NextRequest, context: { params: { id: string } }) {
  const { id } = context.params;
  try {
    await prisma.agent.delete({ where: { id } });
    return NextResponse.json({ success: true });
  } catch (e) {
    return NextResponse.json({ error: 'Agent not found' }, { status: 404 });
  }
}

export async function PUT(req: NextRequest, context: { params: { id: string } }) {
  const { id } = context.params;
  const body = await req.json();
  try {
    const agent = await prisma.agent.update({
      where: { id },
      data: {
        status: body.status,
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
    return NextResponse.json(agent);
  } catch (e) {
    return NextResponse.json({ error: 'Agent not found' }, { status: 404 });
  }
} 