"use client";

/**
 * The client boundary for the whole component library.
 *
 * Every interactive SeaKim component keeps hover, press, and selection state
 * internally, so all of them are Client Components. Rather than adding "use client"
 * to every component file — which would couple the shared library to Next — this one directive
 * marks everything re-exported below.
 *
 * Import from here, never from the component files directly:
 *
 *     import { Button, Field, Input } from "@/lib/seakim";
 *
 * Adjust "@/seakim" to wherever the design system lives in your app.
 */

export { Icon } from "@/seakim/components/core/Icon.jsx";
export { Button } from "@/seakim/components/core/Button.jsx";
export { IconButton } from "@/seakim/components/core/IconButton.jsx";
export { Badge } from "@/seakim/components/core/Badge.jsx";
export { Tag } from "@/seakim/components/core/Tag.jsx";
export { Card } from "@/seakim/components/core/Card.jsx";
export { Avatar } from "@/seakim/components/core/Avatar.jsx";
export { Stat } from "@/seakim/components/core/Stat.jsx";

export { Field } from "@/seakim/components/forms/Field.jsx";
export { Input } from "@/seakim/components/forms/Input.jsx";
export { Textarea } from "@/seakim/components/forms/Textarea.jsx";
export { Select } from "@/seakim/components/forms/Select.jsx";
export { Checkbox } from "@/seakim/components/forms/Checkbox.jsx";
export { Radio } from "@/seakim/components/forms/Radio.jsx";
export { Switch } from "@/seakim/components/forms/Switch.jsx";
export { SegmentedControl } from "@/seakim/components/forms/SegmentedControl.jsx";
export { Slider } from "@/seakim/components/forms/Slider.jsx";
export { DatePicker } from "@/seakim/components/forms/DatePicker.jsx";

export { Table } from "@/seakim/components/data/Table.jsx";

export { Dialog } from "@/seakim/components/feedback/Dialog.jsx";
export { Toast } from "@/seakim/components/feedback/Toast.jsx";
export { Tooltip } from "@/seakim/components/feedback/Tooltip.jsx";
export { EmptyState } from "@/seakim/components/feedback/EmptyState.jsx";

export { Tabs } from "@/seakim/components/navigation/Tabs.jsx";
export { SideNav } from "@/seakim/components/navigation/SideNav.jsx";
export { TabBar } from "@/seakim/components/navigation/TabBar.jsx";

export { Viewport, useMeasuredBreakpoint, breakpointFor, BREAKPOINTS } from "@/seakim/ui_kits/shared/Frames.jsx";

export { useSkTheme } from "./useSkTheme";
