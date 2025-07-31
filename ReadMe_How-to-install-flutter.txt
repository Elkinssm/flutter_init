COMO INSTALAR FLUTTER

Para instalar flutter dirígete al enlace de la pagina principal de flutter y selecciones 'Get started' https://flutter.dev/ , selecciona tu plataforma y el tipo de aplicación a desarrollar, luego baja a la sección 'Install the Flutter SDK' y selecciona 'Download and install'.

1.1 Descarga el archivo comprimido del instalador de flutter y extrae el archivo.

1.2 Crea un directorio donde puedas mover flutter, este directorio debe tener uso publico para impedir que el path que se va a establecer falle al momento de buscar los archivos de flutter.

Se sugiere: #USERPROFILE#\dev\

Para confirmar que todo funciona, abre PowerShell o CMD y escribe 'flutter doctor' para actualizar y lanzar un estado de la instalación. Normalmente puede mostrar errores.

En caso de tener un error en la viñeta 'Android Studio', dirígete a la ubicación de tus archivos 'C:\Program Files\Android\Android Studio\jbr\' , copia todos los archivos y pegalos en 'C:\Program Files\Android\Android Studio\jre\' , ejecuta nuevamente 'flutter doctor' para comprobar si continua fallando

1.3 Aceptar las licencias de android

Ejecuta 'flutter doctor --android-licenses' y confirma todas las licencias

**Visual Studio Code cuenta con el servicio móvil para visualizar las interfaces de usuario. En caso de querer visualizar las interfaces en un dispositivo con características especificas, se recomienda crear un dispositivo en el emulador de Android Studio y seleccionarlo en Visual Studio para compilar las interfaces**

ACTUALIZA TUS VARIABLES DE ENTORNO

Busca 'environment variables' en configuraciones de tu sistema, selecciona 'Environment Variables'.

2. Crea una nueva variable con el nombre 'Path', y en el campo valor coloca la dirección del archivo 'bin' de flutter anteriormente extraído.

    #USERPROFILE#\dev\flutter\bin

EXTENSIONES

Para mas comodidad al desarrollar con dart y flutter en visual studio code, se recomienda descargar estas extensiones:

- Awesome Flutter Snippets //Para recibir sugerencias y trabajar de forma mas eficiente.

- Dart // Lenguaje para desarrollar interfaces

- Flutter // Framework para la construcción de interfaces

- Pubspec Assist // Para agregar o actualizar dependencias fácilmente

