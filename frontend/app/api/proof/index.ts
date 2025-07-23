import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET() {
  const proofs = await prisma.onchainProof.findMany({ orderBy: { timestamp: 'desc' } });
  return NextResponse.json(proofs);
}

export async function POST(req: NextRequest) {
  const data = await req.json();
  const proof = await prisma.onchainProof.create({ data });
  return NextResponse.json(proof);
} 