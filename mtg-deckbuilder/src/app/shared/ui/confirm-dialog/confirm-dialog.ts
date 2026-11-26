import { Component, input, output } from '@angular/core';

@Component({
  selector: 'app-confirm-dialog',
  standalone: true,
  templateUrl: './confirm-dialog.html',
  styleUrl: './confirm-dialog.scss',
  host: { '(document:keydown.escape)': 'cancelled.emit()' }
})
export class ConfirmDialog {
  readonly title = input.required<string>();
  readonly message = input('');
  readonly confirmLabel = input('Delete');

  readonly confirmed = output<void>();
  readonly cancelled = output<void>();
}