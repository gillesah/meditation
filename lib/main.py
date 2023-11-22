import flet as ft
from flet import (
    AppBar, Column, Container, Divider, Image, Page, Row, Text,
    ElevatedButton, TextStyle, FontWeight, MainAxisAlignment, ButtonStyle
)
from datetime import timedelta
import simpleaudio as sa
from duration_picker import durationpicker

# Define music assets
music_assets = {
    "La mer": "mer.mp3",
    "OM 417Hz": "om417.mp3",
    "Son du Bol": "bol.mp3",
    "Son Blanc": "blanc.mp3",
}

# Define global variables
selected_music = None
meditation_duration = timedelta(minutes=15)

# Define functions


def play_button():
    global selected_music
    if selected_music is None:
        ft.MessageBox(
            "Veuillez sélectionner un son avant de lancer la méditation.")
        return
    # Play the selected music
    player = ft.audio.Player()
    player.play(music_assets[selected_music])

    # Start the timer
    timer = ft.timer.Timer(meditation_duration, on_timer_end)
    timer.start()


def on_timer_end():
    # Play the gong sound
    gong_player = ft.audio.Player()
    gong_player.play("gong.wav")

    # Show a message indicating the meditation is over
    ft.alert(
        title="Méditation terminée",
        content="Félicitations pour avoir terminé votre méditation de " +
              str(meditation_duration) + " minutes!",
    )


# La page
def build(page: ft.page):
    duration_widgets = durationpicker(page)
    content = ft.Column(
        ft.Text("Choisir le son"),
        # ft.Row(
        #     music_button(
        #         "La mer", music_assets["La mer"]),
        #     music_button(
        #         "OM 417Hz", music_assets["OM 417Hz"]),
        #     music_button(
        #         "Son du Bol", music_assets["Son du Bol"]),
        #     music_button(
        #         "Son Blanc", music_assets["Son Blanc"]),
        # ),


        ft.Divider(),
        ft.Text("Choisir la durée"),
        # Ajouter les widgets de durationpicker
        # duration_widgets,  # Utiliser l'opérateur de déballage *
        ft.ElevatedButton(
            text="Lancer la méditation",
            on_click=play_button
        )

    )
    # TITRE DE LA PAGE
    page.appbar = ft.AppBar(
        title=Text("ZenFlow"),
        actions=[
            ft.ElevatedButton(
                text="Informations",
                icon=ft.Image(src="info.png"),
                on_click=lambda e: ft.dialog(
                    content=info_dialog(), title="Informations")
            )
        ],
        center_title=True
    )
    # CONTENU DE LA PAGE
    page.add(
        ft.Container(
            content=content
        )
    )

# Define the music selection button


def music_button(label, music_file):
    global selected_music

    def on_click():
        global selected_music
        selected_music = music_file

    return ElevatedButton(
        text=label,
        on_click=on_click,
        #     style=ButtonStyle(
        #         # border_radius=20,
        #         # padding=ft.EdgeInsets.all(10),
        #         background_color=ft.colors.INDIGO_600(
        #             67, 100, 247) if selected_music == music_file else ft.colors.GREY_50
        #     ),
    )
# Define the information dialog


def info_dialog():
    return Column(
        children=[
            Text("Informations", style=TextStyle(
                color=ft.colors.GREY_50, font_size=20, weight=FontWeight)),
            Text(
                "Ce programme permet de méditer en écoutant une musique relaxante.",
                style=TextStyle(color=ft.colors.GREY_50, font_size=16,
                                weight=FontWeight),
            ),
            Text(
                "Pour commencer, sélectionnez une musique et une durée de méditation.",
                style=TextStyle(color=ft.colors.GREY_50, font_size=16,
                                weight=FontWeight),
            ),
            Text(
                "Une fois la méditation commencée, vous pouvez arrêter ou mettre en pause la musique à tout moment.",
                style=TextStyle(color=ft.colors.GREY_50, font_size=16,
                                weight=FontWeight),
            ),
            Text(
                "À la fin de la méditation, un son de gong retentira pour vous indiquer que la séance est terminée.",
                style=TextStyle(color=ft.colors.GREY_50, font_size=16,
                                weight=FontWeight),
            ),
        ],
    )

# Define the main function


ft.app(target=build)
# def main():
#     app = ft.app(target=build)
#     app.run()


# if __name__ == "__main__":
#     main()
