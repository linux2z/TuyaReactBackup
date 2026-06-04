from PIL import Image, ImageDraw

def crop_to_circle(img_path, out_path):
    img = Image.open(img_path).convert("RGBA")
    # create a mask
    mask = Image.new("L", img.size, 0)
    draw = ImageDraw.Draw(mask)
    draw.ellipse((0, 0) + img.size, fill=255)
    
    img.putalpha(mask)
    img.save(out_path, format="PNG")

if __name__ == "__main__":
    crop_to_circle("assets/Logo.jpeg", "android/app/src/main/res/drawable/logo_round.png")
