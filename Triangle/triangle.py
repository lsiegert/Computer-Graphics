# Lauren Siegert
# Color Triangle

size(300,300)
background(0, 0, 0)
width, height = WIDTH, HEIGHT

# vertices for the triangle
xa, ya = 50, 150
xb, yb = 0, 50
xc, yc = 150, 50

# colors of the vertices
c0 = color(255,0,0)
c1 = color(0,0,255)
c2 = color(0,255,0)

def fab(x,y):
    return (((ya - yb) * x) + ((xb-xa) * y) + (xa * yb) - (xb * ya)) * 1.0

def fac(x,y):
    return (((ya - yc) * x) + ((xc-xa) * y) + (xa * yc) - (xc * ya)) * 1.0

ppmfile=open('colortriangle.ppm','wb')
ppmfile.write("P3\n%d %d\n" % (width, height)) 
ppmfile.write("255\n")

# calculate alpha, beta, and gamma for all points
for y in range(300):
    for x in range(300):
        beta = fac(x,y)/fac(xb,yb)
        gamma = fab(x,y)/fab(xc,yc)
        alpha = 1 - beta - gamma
        
        # color pixel if it is inside the triangle
        if (0 < beta < 1 and 0 < alpha < 1 and 0 < gamma < 1):
            r = alpha * c0.r + beta * c1.r + gamma * c2.r
            g = alpha * c0.g + beta * c1.g + gamma * c2.g
            b = alpha * c0.b + beta * c1.b + gamma * c2.b
            fill(r,g,b)
            oval(x,y,1,1)
            # write to ppm file (in same directory as triangle.py)
            ppmfile.write("%d %d %d\n" % (r,g,b))
        else:
            ppmfile.write("0 0 0 \n")
            
ppmfile.close()