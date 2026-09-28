from PIL import Image

path = r'C:/Users/Dr.pc/.gemini/antigravity/brain/ca364fbd-9b45-4c98-84de-effb0e728805/.user_uploaded/media_1790618350599.png'
img = Image.open(path)
print(f"Dimensions: {img.width}x{img.height}")
