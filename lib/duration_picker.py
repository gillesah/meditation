import flet as ft


def durationpicker(page: ft.Page):
    # State variables for hours and minutes
    hours = 0
    minutes = 15

    # Event handlers to update hours and minutes
    def update_hours(e):
        nonlocal hours
        hours = int(e.control.value)

    def update_minutes(e):
        nonlocal minutes
        minutes = int(e.control.value)

# LES DROPDOWNS
    hours_dropdown = ft.Dropdown(
        value=str(hours),
        options=[str(i) for i in range(24)],
        on_change=update_hours
    )

    minutes_dropdown = ft.Dropdown(
        value=str(minutes),
        options=[str(i) for i in range(60)],
        on_change=update_minutes
    )

    # Display the selected duration
    selected_duration_text = ft.Text(
        f"Selected Duration: {hours} hours, {minutes} minutes")

    return [hours_dropdown, minutes_dropdown, selected_duration_text]


# if __name__ == "__main__":
#     ft.app(target=main)
