import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET() {
  const items = await prisma.contentItem.findMany({
    orderBy: { timestamp: 'desc' },
  });
  return NextResponse.json(items);
}

export async function POST(req: NextRequest) {
  const data = await req.json();
  const item = await prisma.contentItem.create({ data });
  return NextResponse.json(item);
} 