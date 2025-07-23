import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET() {
  const votes = await prisma.validationVote.findMany({ orderBy: { createdAt: 'desc' } });
  return NextResponse.json(votes);
}

export async function POST(req: NextRequest) {
  const data = await req.json();
  const vote = await prisma.validationVote.create({ data });
  return NextResponse.json(vote);
} 