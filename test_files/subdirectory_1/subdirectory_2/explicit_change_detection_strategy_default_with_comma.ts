import { ChangeDetectionStrategy, Component } from '@angular/core'

@Component({
	selector: 'app-test',
	template: `
		<div>
			Test component
		</div>
	`,
	standalone: true,
	changeDetection: ChangeDetectionStrategy.Default,
})
export class TestComponent {
}
