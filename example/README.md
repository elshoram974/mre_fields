# mre_fields example

A demo of every piece of the package: text direction, the text field, image
paste and theming.

```bash
flutter run               # pick any device: phone, desktop or web
flutter run -d chrome
```

The home page has one card per feature. The buttons in the app bar switch light
and dark, and English and Arabic. The radius slider changes `MREFieldsTheme` for
the whole app.

`?demo=text` and `?demo=paste` on the web build show the clean pages recorded
for the documentation GIFs (`tool/demo/make_gifs.sh` rebuilds them).
