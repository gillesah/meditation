import flet as ft
from flet import (AppBar, Button, Column, Container,
                  Divider, Image, Page, Row, Text)
from datetime import timedelta
import simpleaudio as sa

# Define music assets
music_assets = {
    "La mer": "mer.mp3",
    "OM 417Hz": "om417.mp3",
    "Son du Bol": "bol.mp3",
    "Son Blanc": "blanc.mp3",
}

# Define global variables
selected_music = None
meditation_duration = Duration(minutes=15)

# Define functions


def play_button():
    # Check if a music is selected
    if selected_music is None:
        return Text("Veuillez sélectionner un son avant de lancer la méditation.")

    # Play the selected music
    player = flet.audio.Player()
    player.play(music_assets[selected_music])

    # Start the timer
    timer = flet.timer.Timer(meditation_duration, on_timer_end)
    timer.start()


def on_timer_end():
    # Play the gong sound
    gong_player = flet.audio.Player()
    gong_player.play("gong.wav")

    # Show a message indicating the meditation is over
    flet.alert(
        title="Méditation terminée",
        content="Félicitations pour avoir terminé votre méditation de " +
              str(meditation_duration) + " minutes!",
    )


# Define the layout
def build():
    return Page(
        appbar=AppBar(
            title=Text("ZenFlow"),
            backgroundColor=Color.from_rgb(15, 25, 63),
            title_text_style=TextStyle(
                color=Colors.white, font_size=25, weight=FontWeight.w600),
            actions=[
                Button(
                    text="Informations",
                    icon=Image(src="info.png"),
                    on_click=lambda e: flet.dialog(content=info_dialog(), title="Informations")),
            ],
            center_title=True,
        ),
        body=Container(
            color=Color.from_rgb(15, 25, 63),
            content=Column(
                children=[
                    Container(
                        padding=EdgeInsets.all(12),
                        content=Column(
                            cross_axis_alignment=CrossAxisAlignment.center,
                            children=[
                                Text(
                                    "Choisir le son",
                                    style=TextStyle(color=Colors.white,
                                                    font_size=20, weight=FontWeight.w600),
                                ),
                                SingleChildScrollView(
                                    scroll_direction=Axis.horizontal,
                                    content=Row(
                                        main_axis_alignment=MainAxisAlignment.space_evenly,
                                        children=[
                                            music_button(
                                                "La mer", music_assets["La mer"]),
                                            music_button(
                                                "OM 417Hz", music_assets["OM 417Hz"]),
                                            music_button(
                                                "Son du Bol", music_assets["Son du Bol"]),
                                            music_button(
                                                "Son Blanc", music_assets["Son Blanc"]),
                                        ],
                                    ),
                                ),
                            ],
                        ),
                    ),
                    Divider(),
                    Text(
                        "Choisir la durée",
                        style=TextStyle(color=Colors.white, font_size=20,
                                        weight=FontWeight.w600),
                    ),
                    DurationPicker(
                        duration=meditation_duration,
                        on_change=lambda val: meditation_duration.update(
                            minutes=val),
                    ),
                    Button(
                        text="Lancer la méditation",
                        on_click=play_button,
                    ),
                ],
            ),
        ),
    )

# Define the music selection button


def music_button(label, music_file):
    global selected_music

    def on_click():
        global selected_music
        selected_music = music_file
        build()

    return Button(
        text=label,
        on_click=on_click,
        style=ButtonStyle(
            border_radius=RoundedRectangleBorder(radius=20),
            padding=EdgeInsets.all(10),
            color=Color.from_rgb(
                67, 100, 247) if selected_music == music_file else Colors.transparent,
        ),
    )
# Define the information dialog
def info_dialog():
  return Column(
    children=[
      Text("Informations", style=TextStyle(color=Colors.white, font_size=20, weight=FontWeight.w600)),
      Text(
        "Ce programme permet de méditer en écoutant une musique relaxante.",
        style=TextStyle(color=Colors.white, font_size=16, weight=FontWeight.w400),
      ),
      Text(
        "Pour commencer, sélectionnez une musique et une durée de méditation.",
        style=TextStyle(color=Colors.white, font_size=16, weight=FontWeight.w400),
      ),
      Text(
        "Une fois la méditation commencée, vous pouvez arrêter ou mettre en pause la musique à tout moment.",
        style=TextStyle(color=Colors.white, font_size=16, weight=FontWeight.w400),
      ),
      Text(
        "À la fin de la méditation, un son de gong retentira pour vous indiquer que la séance est terminée.",
        style=TextStyle(color=Colors.white, font_size=16, weight=FontWeight.w400),
      ),
    ],
  )

# Define the main function
def main():
  app = flet.App(build)
  app.run()

if __name__ == "__main__":
  main()