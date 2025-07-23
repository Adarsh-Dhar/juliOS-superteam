import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET() {
  const events = await prisma.event.findMany({ orderBy: { timestamp: 'desc' } });
  return NextResponse.json(events);
}

export async function POST(req: NextRequest) {
  const data = await req.json();
  const event = await prisma.event.create({ data });
  return NextResponse.json(event);
} 