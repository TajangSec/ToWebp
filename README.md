# ToWebp

[中文](#中文)   [English](#English)

#### 中文：

本项目用于将指定目录内的所有 jpg、png图像转换为webp格式，包含子目录里的文件，并且保持文件夹结构。

对于非 jpg、png格式图像会复制到相应目录内。

如果同一文件夹内的两个文件转换后同名，则在保存时自动添加“ (1)”后缀

ep：one.jpg、one.png ===>one.webp、one.webp (1).webp

<h6 style="color:red">注意：请填写输入目录、输出目录、cwebp.exe的绝对路径</h6>

本项目已经包含cwebp.exe

关于cwebp的Windows可执行文件编译：https://chromium.googlesource.com/webm/libwebp/+/HEAD/doc/building.md

#### English：

This project is used to convert all jpg and png images within a specified directory to webp format, including files in subdirectories, while maintaining the folder structure.

Images in non-JPG or PNG formats will be copied to the corresponding directory.

If two files in the same folder have the same name after conversion, a "(1)" suffix will be automatically added when saving

ep: one.jpg, one.png ===> one.webp, one.webp (1).webp

<h6 style="color:red">Note: Please fill in the input directory, output directory, and the absolute path of cwebp.exe</h6>

This project already includes cwebp.exe.

Regarding the compilation of the Windows executable for cwebp: https://chromium.googlesource.com/webm/libwebp/+/HEAD/doc/building.md