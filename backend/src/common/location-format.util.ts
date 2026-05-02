type LocationPart = { name: string } | null | undefined;

export function formatLocation(
  ward?: LocationPart,
  province?: LocationPart,
  detail?: string | null,
): string | null {
  const parts = [detail, ward?.name, province?.name].filter(Boolean);
  return parts.length > 0 ? parts.join(', ') : null;
}