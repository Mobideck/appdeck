package com.mortennobel.imagescaling;

public class Dimension {

    public int width;
    public int height;

    Dimension(Dimension dimension) {
        width = dimension.width;
        height = dimension.height;
    }

    Dimension(int width, int height) {
        this.width = width;
        this.height = height;
    }

    public Dimension getSize() {
        return new Dimension(width, height);
    }
    public void setSize(Dimension d) {
        width = d.width;
        height = d.height;
    }
    public void setSize(int width, int height) {
        this.width = width;
        this.height = height;
    }


}
