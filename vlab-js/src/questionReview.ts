import { Grid, html } from "gridjs";
import Toastify from "toastify-js";

const CHECKED_ICON_HTML = `<i class="fa-solid fa-circle-check"></i>`;
const UNCHECKED_ICON_HTML = `<i class="fa-solid fa-circle-xmark"></i>`;
let grid: Grid;

/**
 *
 * @param dataLabel The question dataLabel attribute
 */
const scrollToQuestion = (dataLabel: string) => {
    let sectionId: string;
    let topicIndex: number = -1;
    let questionEl: HTMLElement = null;

    //Find the parent section id
    document.querySelectorAll(".topics > .section").forEach((section) => {
        if (
            section.querySelectorAll(`[data-label="${dataLabel}"]`).length > 0
        ) {
            // console.log(section.id);
            // console.log(
            //     section.querySelectorAll(`[data-label="${dataLabel}"]`)
            // );
            sectionId = section.id;
        }
    });

    //Find the topic index of that section
    document.querySelectorAll(".topics > .section").forEach((sectionEl, i) => {
        if (sectionEl.id === sectionId) {
            topicIndex = i;
            console.log("topicIndex", i);
        }
    });

    //Click on the topic
    (
        document.querySelectorAll(".topic")[topicIndex] as HTMLButtonElement
    ).click();

    questionEl = document.querySelector(`[data-label="${dataLabel}"]`);

    //find the section of the question
    let sectionEl: HTMLDivElement = questionEl.closest(".section");

    // console.log(sectionEl);

    if (sectionEl.classList.contains("hide")) {
        sectionEl.classList.remove("hide");
        sectionEl.classList.add("vlab--question-preview"); //Add a class to the section to make it visible
        sectionEl.classList.add("animate__heartBeat");
        //  console.log("is hidden");
        Toastify({
            text: "Please complete the previous question before continuing!",
            style: {
                background: "linear-gradient(to right, #00b09b, #96c93d)",
            },
            gravity: "bottom",
            duration: 3000,
            close: true,
        }).showToast();
    }

    //Smooth scroll to the question
    questionEl.scrollIntoView({
        behavior: "smooth",
    });

    // document.querySelector(questionEl).scrollIntoView();
};

const getOption = (message: any, optionName: string) => {
    let mark = "N/A";
    //  console.log("optionName", optionName);
    for (const item of message.get_tutorial_info.items.data) {
        if (item.label === optionName) {
            if (item.options.hasOwnProperty("mark")) {
                mark = String(item.options.mark);
            }
            break;
        }
    }

    return mark;
    ///    return "N/A";
};

const getStateItem = (message: any, label: string) => {
    for (const item of message.get_all_state_objects) {
        if (item.id === label) {
            console.log(item);
            return item;
        }
    }
};

//@ts-ignore
Shiny.addCustomMessageHandler("vlab_state_update", (message: any) => {
    const container = document.getElementById("vlab_review");

    console.log(message);

    const data: Array<any> = [];

    message.label.forEach((label: string) => {
        console.log(getStateItem(message, label));
        data.push({
            name: label,
            attempted: getStateItem(message, label) ? true : false,
            correct: Math.random() > 0.5,
            mark: getOption(message, label),
        });
    });

    if (!grid) {
        grid = new Grid({
            columns: [
                {
                    id: "name",
                    name: "Name",
                    formatter: (_, row) => {
                        return html(
                            `<div class="vlab--question-link" role="button">${row.cells[0].data}</div>`
                        );
                    },
                    //onclick
                    onclick: (e: any) => {
                        scrollToQuestion(e.data.name);
                    },
                },
                {
                    id: "attempted",
                    name: "Attempted",
                    formatter: (_, row) => {
                        return html(
                            row.cells[1].data == true ? CHECKED_ICON_HTML : ``
                        );
                    },
                },
                {
                    id: "correct",
                    name: "Correct",
                    formatter: (_, row) =>
                        html(
                            row.cells[2].data == true
                                ? CHECKED_ICON_HTML
                                : UNCHECKED_ICON_HTML
                        ),
                },
                {
                    id: "mark",
                    name: "Mark",
                },
            ],
            search: true,
            sort: true,
            data,
        }).render(container);
        //@ts-ignore
        grid.on("cellClick", (_e, listener, cell, _col) => {
            //The user clicked on the name cell
            if (cell.id == "name") {
                //We scroll to the question
                //@ts-ignore
                scrollToQuestion(listener.data);
            }
        });
    } else {
        grid.updateConfig({
            data,
        }).forceRender();
    }
});
