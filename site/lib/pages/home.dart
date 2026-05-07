import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

@client
class Home extends StatefulComponent {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  @override
  Component build(BuildContext context) {
    return div([
      nav([
        div(classes: 'logo', [
          Component.text('DASH'),
          span(classes: 'text-teal', [Component.text('LANDER')]),
        ]),
        div([
          a(href: '#', classes: 'text-yellow play-link', [Component.text('PLAY V1.0')]),
        ]),
      ]),

      header(classes: 'hero', [
        h1(classes: 'text-teal', [
          Component.text('DASH'),
          span(classes: 'text-magenta', [Component.text('LANDER')]),
        ]),
        p([
          Component.text(
            'A low-fidelity, high-stakes vector lunar landing simulation. Manage your fuel, calculate your trajectory, and find the neon safe zones before gravity takes over.',
          ),
        ]),
        a(href: '/app/', classes: 'btn', [Component.text('Initiate Sequence')]),
      ]),

      section(classes: 'game-states', [
        div(classes: 'card gameplay', [
          h3(classes: 'text-magenta', [Component.text('Vector Dynamics')]),
          p([
            Component.text(
              'Navigate procedurally generated, jagged terrain. Watch your telemetry—velocity is your enemy.',
            ),
          ]),
          ul(classes: 'stats-list', [
            li([
              span([Component.text('FUEL')]),
              span(classes: 'text-teal', [Component.text('1000 kg')]),
            ]),
            li([
              span([Component.text('V.SPD')]),
              span(classes: 'text-magenta', [Component.text('8.8 m/s')]),
            ]),
            li([
              span([Component.text('TILT')]),
              span(classes: 'text-yellow', [Component.text('3.3°')]),
            ]),
          ]),
        ]),
        div(classes: 'card touchdown', [
          h3(classes: 'text-teal', [Component.text('Flawless Touchdown')]),
          p([
            Component.text(
              'Align the landing gear. Cancel out horizontal drift. Execute the perfect landing to maximize your mission score.',
            ),
          ]),
          ul(classes: 'stats-list', [
            li([
              span([Component.text('STATUS')]),
              span(classes: 'text-teal', [Component.text('FLAWLESS EXECUTION')]),
            ]),
            li([
              span([Component.text('IMPACT')]),
              span(classes: 'text-teal', [Component.text('2.4 m/s')]),
            ]),
            li([
              span([Component.text('SCORE')]),
              span(classes: 'text-yellow', [Component.text('878')]),
            ]),
          ]),
        ]),
        div(classes: 'card catastrophe', [
          h3(classes: 'text-red', [Component.text('Catastrophe')]),
          p([
            Component.text(
              'Impacted raw jagged terrain. Missing the pad or coming in too hot results in total structural failure.',
            ),
          ]),
          ul(classes: 'stats-list', [
            li([
              span([Component.text('STATUS')]),
              span(classes: 'text-red', [Component.text('OFF-PAD CRASH')]),
            ]),
            li([
              span([Component.text('V.SPD')]),
              span(classes: 'text-red', [Component.text('14.6 m/s')]),
            ]),
            li([
              span([Component.text('RECOMMEND')]),
              span(classes: 'text-yellow', [Component.text('RETRY')]),
            ]),
          ]),
        ]),
      ]),

      section(id: 'gallery', classes: 'gallery', [
        h2(classes: 'text-yellow', [Component.text('MISSION LOGS')]),
        div(classes: 'grid-container', [
          div(classes: 'screenshot-wrap grid-item-wide', [
            img(src: 'screenshot-gameplay.jpg', alt: 'Dashlander Gameplay Screen'),
            div(classes: 'caption text-magenta', [Component.text('Telemetry Active // Descent Initiated')]),
          ]),
          div(classes: 'screenshot-wrap', [
            img(src: 'screenshot-victory.jpg', alt: 'Dashlander Touchdown Screen'),
            div(classes: 'caption text-teal', [Component.text('Success // Mission Score Authorized')]),
          ]),
          div(classes: 'screenshot-wrap', [
            img(src: 'screenshot-defeat.jpg', alt: 'Dashlander Catastrophe Screen'),
            div(classes: 'caption text-red', [Component.text('Critical Failure // Hull Breach Detected')]),
          ]),
        ]),
      ]),

      footer([
        p([Component.text('© 2026 DASHLANDER. BUILT WITH FLUTTER. ALL SYSTEMS NOMINAL.')]),
      ]),
    ]);
  }
}
