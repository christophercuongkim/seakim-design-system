export function Button({ active }) {
  return <button style={{ transform: active ? 'scale(0.97)' : 'scale(1)' }} />;
}
