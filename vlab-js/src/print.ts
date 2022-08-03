//@ts-ignore
import html2pdf from "html2pdf.js";
import Toastify from "toastify-js";

//Where we print the lab

export const print = async () => {
    // let doc = new jsPDF();

    setMaxLines(Infinity);

    // html2canvas(document.body).then((canvas) => {
    //     document.body.appendChild(canvas);
    //     doc.addImage(canvas.toDataURL("image/png"), "PNG", 0, 0, 210, 297);
    //     setMaxLines(15); //Set the max lines back to the default
    // });

    let currentSectionEl: HTMLElement; //Store the current element that the user is in

    //loop through all section elements
    document
        .querySelectorAll("[id^='section-']")
        .forEach((sectionEl: HTMLElement) => {
            //check if sectionEl contains "current" class
            if (!currentSectionEl && sectionEl.classList.contains("current")) {
                currentSectionEl = sectionEl; //Store the current viewing section
            } else {
                sectionEl.classList.add("current"); //add the current class
            }
        });

    Toastify({
        text: "Printing...",
        style: {
            background: "linear-gradient(to right, #00b09b, #96c93d)",
        },
        gravity: "bottom",
        duration: 3000,
        close: true,
    }).showToast();

    await new Promise((resolve) => setTimeout(resolve, 2000));

    //Print the topics class
    await html2pdf()
        .set({ margin: 10 })
        .from(document.querySelector(".topics"))
        .save();

    //After print restore the current section
    document.querySelectorAll("[id^='section-']").forEach((sectionEl) => {
        if (currentSectionEl.id !== sectionEl.id) {
            sectionEl.classList.remove("current");
        }
    });

    currentSectionEl = null; //reset the current section
};

//A fix for the ace editor not showing all code lines
const setMaxLines = (maxLines: number) => {
    document.querySelectorAll(".ace_editor").forEach((el) => {
        //@ts-ignore
        el.env.editor.setOptions({
            maxLines,
        });
    });
};
