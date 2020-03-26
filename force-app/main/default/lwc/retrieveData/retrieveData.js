import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import retrieveData from "@salesforce/apex/ucl_RetrieveDataController.retrieveData";

export default class RetrieveData extends LightningElement {
    handleRetrieveData() {
        this.showToast();
        retrieveData()
            .then(() => {
                console.log("finished");
            })
            .catch(error => {
                console.log(error);
            });
    }

    showToast() {
        const event = new ShowToastEvent({
            title: "Retrieving data...",
            message: "This might take a while",
            variant: "success"
        });
        this.dispatchEvent(event);
    }
}