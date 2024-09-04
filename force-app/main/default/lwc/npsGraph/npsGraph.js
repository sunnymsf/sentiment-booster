import { LightningElement, api } from 'lwc';

export default class NpsGraph extends LightningElement {
    @api pointerValue = 75; // Configurable value to point at

    get barStyle() {
        return 'background: linear-gradient(to right, green, yellow, orange, red); height: 20px; width: 100%;';
    }

    get pointerStyle() {
        return `left: calc(${this.pointerValue}% - 10px);`; // Adjust position of the pointer
    }
}