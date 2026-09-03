(() => {
  const selector = ".post-content img, .browse-reader-content img";
  let lastFocusedImage;

  const dialog = document.createElement("dialog");
  dialog.className = "image-lightbox";
  dialog.setAttribute("aria-label", "Expanded image preview");

  const closeButton = document.createElement("button");
  closeButton.className = "image-lightbox-close";
  closeButton.type = "button";
  closeButton.setAttribute("aria-label", "Close image preview");
  closeButton.textContent = "×";

  const preview = document.createElement("img");
  const caption = document.createElement("p");
  caption.className = "image-lightbox-caption";
  dialog.append(closeButton, preview, caption);
  document.body.append(dialog);

  function close() {
    if (dialog.open) dialog.close();
  }

  function open(image) {
    lastFocusedImage = image;
    preview.src = image.currentSrc || image.src;
    preview.alt = image.alt;
    caption.textContent = image.alt;
    caption.hidden = !image.alt;
    dialog.showModal();
    closeButton.focus();
  }

  document.querySelectorAll(selector).forEach((image) => {
    if (image.closest("a") || image.dataset.noLightbox !== undefined) return;
    image.classList.add("image-lightbox-trigger");
    image.tabIndex = 0;
    image.setAttribute("role", "button");
    image.setAttribute("aria-haspopup", "dialog");
    image.addEventListener("click", () => open(image));
    image.addEventListener("keydown", (event) => {
      if (event.key === "Enter" || event.key === " ") {
        event.preventDefault();
        open(image);
      }
    });
  });

  closeButton.addEventListener("click", close);
  dialog.addEventListener("click", (event) => {
    if (event.target === dialog) close();
  });
  dialog.addEventListener("close", () => {
    preview.removeAttribute("src");
    lastFocusedImage?.focus();
  });
})();
