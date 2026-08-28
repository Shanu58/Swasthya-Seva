from paddleocr import PaddleOCR


ocr = PaddleOCR(
    lang="en",
)


def extract_text_from_image(
    image_path: str,
) -> list[str]:

    results = ocr.predict(
        image_path,
    )

    texts = []

    for result in results:
        recognized_texts = result["rec_texts"]

        for text in recognized_texts:
            text = text.strip()

            if text:
                texts.append(text)

    return texts
