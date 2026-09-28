from PIL import Image

def remove_white_bg(img_path, out_path):
    img = Image.open(img_path).convert("RGBA")
    data = img.getdata()
    new_data = []
    for item in data:
        # If pixel is close to white, make transparent
        if item[0] > 240 and item[1] > 240 and item[2] > 240:
            new_data.append((255, 255, 255, 0))
        else:
            new_data.append(item)
    img.putdata(new_data)
    img.save(out_path, "PNG")

remove_white_bg(r"C:\Users\Dr.pc\.gemini\antigravity\brain\ca364fbd-9b45-4c98-84de-effb0e728805\promise_1_1790618434437.jpg", r"assets\images\promise_1.png")
