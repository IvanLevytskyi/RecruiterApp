import { LightningElement, api } from 'lwc';

export default class DisplaySalary extends LightningElement {
    @api salaryFrom; // salary from
    @api salaryTo; // salary to
}