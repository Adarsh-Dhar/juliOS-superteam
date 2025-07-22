import { NextRequest, NextResponse } from 'next/server';

const certificates = [
  { id: '1', name: 'Certificate 1', owner: 'user1' },
  { id: '2', name: 'Certificate 2', owner: 'user2' },
];

export async function GET(req: NextRequest, { params }: { params: { id: string } }) {
  const certificate = certificates.find(c => c.id === params.id);
  if (!certificate) return NextResponse.json({ error: 'Not found' }, { status: 404 });
  return NextResponse.json(certificate);
}

export async function PUT(req: NextRequest, { params }: { params: { id: string } }) {
  const data = await req.json();
  return NextResponse.json({ ...data, id: params.id });
}

export async function DELETE(req: NextRequest, { params }: { params: { id: string } }) {
  return NextResponse.json({ success: true, id: params.id });
} 