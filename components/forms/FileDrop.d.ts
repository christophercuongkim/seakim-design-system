import * as React from 'react';

export interface FileDropFile {
  name: string;
  /** Bytes. Shown as "80.3 KB". */
  size?: number;
}

/**
 * A drop zone around a native file input, with the chosen file as a row beneath,
 * a labelled uploading state on that row (never a bar) and the error rendered under
 * the zone. One file.
 */
export interface FileDropProps extends Omit<React.HTMLAttributes<HTMLDivElement>, 'onError'> {
  /** Same syntax as the input's `accept`: ".pdf", "application/pdf". */
  accept?: string;
  /** Called with the chosen or dropped `File`. */
  onFile?: (file: File) => void;
  /** The chosen file, shown as a row. A `File` works; so does `{ name, size }` from the server. */
  file?: FileDropFile | File | null;
  /** Shows a remove control on the row. */
  onRemove?: () => void;
  /** Replaces the remove control with a labelled uploading state (0021). */
  uploading?: boolean;
  /** Rendered under the zone in the danger colour and announced. */
  error?: string;
  /** The types-and-size line: "PDF up to 5 MB". */
  hint?: string;
  /** Phosphor icon in the zone. Defaults to `upload-simple`; pass `null` for none. */
  icon?: string | null;
  /** The link-coloured verb. Defaults to "Click to upload". */
  action?: string;
  /** The rest of the line. Defaults to "or drag and drop". */
  label?: string;
  disabled?: boolean;
  style?: React.CSSProperties;
}
export declare function FileDrop(props: FileDropProps): JSX.Element;
export declare function formatFileSize(bytes: number): string;
