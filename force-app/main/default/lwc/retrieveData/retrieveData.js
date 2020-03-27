import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import retrieveData from "@salesforce/apex/ucl_RetrieveDataController.retrieveData";

export default class RetrieveData extends LightningElement {
    handleRetrieveData() {
        this.showToast("Retrieving data...", "This might take a while", "success");
        retrieveData()
            .then(() => {
                this.showToast("Finished", "Data was retrieved successfully");
            })
            .catch(() => {
                this.showToast("Finished", "Something went wrong", "error");
            });
    }

    showToast(title, message, variant = "success") {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }
}
