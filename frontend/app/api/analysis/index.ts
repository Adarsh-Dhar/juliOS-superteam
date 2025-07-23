import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET() {
  const results = await prisma.analysisResult.findMany({ orderBy: { timestamp: 'desc' } });
  return NextResponse.json(results);
}

export async function POST(req: NextRequest) {
  const data = await req.json();
  const result = await prisma.analysisResult.create({ data });
  return NextResponse.json(result);
} 