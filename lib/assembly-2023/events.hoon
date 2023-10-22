::
::NOTE  data from the assembly.js & urbitWeek.js as of commit 6995c80
::
::TODO  keep track:
::  https://github.com/urbit/assembly2023/compare/6995c80..master
::
/+  *assembly-2023
::
|%
++  all  ^~(:(weld assembly-1 assembly-2 week-1 week-2 week-3 week-4 week-5))
++  assembly-1
  ^~  ^-  (list [@ event])
  :~  :*  'a100'  %main
          'Registration & Coffee'
          ''
          ''
          ~2023.10.28..09.00.00  ~h1
          ~
          ~['Assembly Lisboa']
          ~
      ==
      :*  'a101'  %main
          'Lunch'
          ''
          ''
          ~2023.10.28..12.00.00  ~h1
          ~
          ~['Assembly Lisboa']
          ~
      ==
    ::
      :*  'a102'  %main
          'Welcome to Assembly'
          ''
          ''
          ~2023.10.28..10.00.00  ~h1
          %main
          ~['Josh Lehman']
          %talk
      ==
      :*  'a103'  %main
          'The Future of Sovereign AI'
          'We still don\'t know just how important and disruptive artificial intelligence will be, but one thing seems clear: the power of AI should not remained cordoned off by centralized companies. Our panelists—Cody Wilson of Defense Distributed, Native Planet\'s ~mopfel-winrux, Tlon\'s Lukas Buhler, along with @mogmachine from Bittensor and David Clarity from Harmless AI—are the perfect team to explore the possibilities unlocked by more sovereign, decentralized, and open AI.'
          ''
          ~2023.10.28..11.00.00  ~h1.m10
          %main
          ~['~mopfel-winrux' 'Cody Wilson' 'Lukas Buhler' 'David Clarity' 'mogmachine']
          %panel
      ==
      :*  'a104'  %main
          'Tlon Presentation'
          ''
          ''
          ~2023.10.28..13.00.00  ~m30
          %main
          ~['Galen Wolfe-Pauly']
          %presentation
      ==
      :*  'a105'  %main
          'Cancelling the Culture Industry'
          'In a world of moral totalitarianism, sometimes freedom looks like a short story about sex tourism in the Philippines. In this panel, author Sam Frank hosts MRB editor in chief Noah Kumin, romance writer Delicious Tacos, sex detective Magdalene Taylor and frog champion Lomez of Passage Press. Join them for a freewheeling discussion of saying whatever they want while evading the digital hall monitors.'
          ''
          ~2023.10.28..13.45.00  ~h1
          %main
          ~['Sam Frank' 'Noah Kumin' 'Delicious Tacos' 'Lomez' 'Magdalene Taylor']
          %panel
      ==
      :*  'a106'  %main
          'Vaporware – Magic and Arbitrage'
          'What might web apps look like if corporations weren\'t responsible for hosting them? How many of you are satisfied with the price, functionality, and design of MEGACORP software? We believe there are at least two categories of application which are technically achievable, commercially valuable, but practically impossible: Arbitrage and Magic. To bring these to market, we need both a new distribution system and a new device type. Both are imminently achievable.'
          ''
          ~2023.10.28..15.00.00  ~m30
          %main
          ~['Chase Van Etten']
          %presentation
      ==
      :*  'a107'  %main
          'Securing Urbit'
          'How do we make Urbit secure? And what does a secure Urbit look like? The great promise of Urbit has always been that it can provide a sovereign computing platform for the individual—a means by which to do everything you would want to do on a computer without giving up your data. For that dream to be fulfilled, Urbit should be as secure as your crypto hardware wallet—perhaps moreso. Moderated by Rikard Hjort, Urbit experts Logan Allen, and Joe Bryan discuss with Urbit fan and cybersecurity expert Ryan Lackey.'
          ''
          ~2023.10.28..15.45.00  ~h1
          %main
          ~['Rikard Hjort' 'Logan Allen' 'Ryan Lackey' 'Joe Bryan']
          %panel
      ==
      :*  'a108'  %main
          'Holium'
          ''
          ''
          ~2023.10.28..17.00.00  ~m30
          %main
          ~['Trent Gillham']
          %presentation
      ==
      :*  'a109'  %main
          'Urbit Foundation'
          ''
          ''
          ~2023.10.28..17.30.00  ~m45
          %main
          ~['Josh Lehman' 'Ted Blackman' 'Thomas Kroes']
          %presentation
      ==
      :*  'a110'  %main
          'The Machine War'
          'Mars Review of Books editor Noah Kumin discusses his book The Machine War, an Urbit-centric history of computing, with publishing veteran Daniel Lisi.'
          ''
          ~2023.10.28..11.00.00  ~m30
          %second
          ~['Noah Kumin' 'Daniel Lisi']
          %presentation
      ==
      :*  'a111'  %main
          'Archetype'
          ''
          ''
          ~2023.10.28..11.30.00  ~m30
          %second
          ~['Seth Feibus']
          %presentation
      ==
      ::
      :*  'a112'  %main
          'Global P2P Securities Markets via Urbit'
          'Trillions in securities will be tokenized over the coming years. In this talk, we present a proof of concept for compliant global P2P transactions of these assets using Urbit.'
          ''
          ~2023.10.28..13.00.00  ~m30
          %second
          ~['Eric Arsenault']
          %presentation
      ==
      :*  'a113'  %main
          'Native Planet'
          'Self hosting maximalism and the newest software and hardware from Native Planet.'
          ''
          ~2023.10.28..13.45.00  ~m30
          %second
          ~['Austin Nelsen' '~mopfel-winrux']
          %presentation
      ==
      :*  'a114'  %main
          'Ares'
          'Edward Amsden, lead developer of Ares, discusses the plans for making Urbit fast, scalable, and more.'
          ''
          ~2023.10.28..14.15.00  ~m30
          %second
          ~['Edward Amsden']
          %talk
      ==
      :*  'a115'  %main
          'Building a Proof-of-Authority Chain on Urbit'
          ''
          ''
          ~2023.10.28..15.00.00  ~m30
          %second
          ~['Sunny Aggarwal']
          %talk
      ==
      :*  'a116'  %main
          'Gaming the System'
          'Transforming gaming was never one of Urbit\'s core aims, but it turns out that Urbit can do some, dare we say, game-changing things when it comes to interactive digital entertainment. Because an urbit is uniquely tied to its user, a gamer on Urbit can carry information about his gameplay or avatar between games, or even beyond them. Vaporware CEO Chase van Etten (builder of the NFTs-on-Urbit game Tharsis), Shadow Wars Creative Director Roy Blackstone, along with Trent Steen, John Hyde, and the mononymous Louis discuss.'
          ''
          ~2023.10.28..15.45.00  ~h1
          %second
          ~['Chase Van Etten' 'Roy Blackstone' 'Louis' 'Trent Steen' 'John Hyde']
          %panel
      ==
      :*  'a117'  %main
          'The Sovereign Stack'
          'Software is eating the world, but it has made a Faustian bargain in its insatiable hunger. The software stack has become grotesquely centralized, with a minuscule number of players controlling most of the infrastructure. The Sovereign Stack is the stack of technologies that can liberate us, enabling the sovereign individual and communities of the 21 century. Urbit can play a pivotal role in this stack. We need to build them now, so they are ready then.'
          ''
          ~2023.10.28..17.00.00  ~m30
          %second
          ~['@odysseas']
          %talk
      ==
      :*  'a118'  %main
          'Decentralized Medicine'
          ''
          ''
          ~2023.10.28..17.30.00  ~m30
          %second
          ~['Jack Kruse']
          %talk
      ==
  ==
::
++  assembly-2
  ^~  ^-  (list [@ event])
  :~  :*  'a200'  %main
          'Registration & Coffee'
          ''
          ''
          ~2023.10.29..09.00.00  ~h1
          ~
          ~['Assembly Lisboa']
          ~
      ==
      :*  'a201'  %main
          'Lunch'
          ''
          ''
          ~2023.10.29..12.00.00  ~h1
          ~
          ~['Assembly Lisboa']
          ~
      ==
      :*  'a202'  %main
          'Red Horizon'
          'Urbit Onboarding Made Easy'
          ''
          ~2023.10.29..10.00.00  ~m30
          %main
          ~['Brian Crain' '~tiller-tolbus']
          %presentation
      ==
      :*  'a203'  %main
          'Tirrel'
          ''
          ''
          ~2023.10.29..10.30.00  ~m30
          %main
          ~['Christian Langalis']
          %presentation
      ==
      :*  'a204'  %main
          'Forking the Economy'
          'You think creating a new internet is hard? Try marketing a new brand of cigarettes in New York. Join fashion designer Elena Velez, publisher Daniel Lisi and tobacco entrepreneur David Sley on this panel with dissident propagandist Isaac Simpson. They\'ll discuss the rewards and challenges of funding, creating and distributing new products on their own terms.'
          ''
          ~2023.10.29..14.00.00  ~h1
          %main
          ~['Isaac Simpson' 'Elena Velez' 'Sean Monahan' 'David Sley' 'Daniel Lisi']
          %panel
      ==
      :*  'a205'  %main
          'Zorp'
          ''
          ''
          ~2023.10.29..13.00.00  ~m45
          %main
          ~['Logan Allen']
          %presentation
      ==
      :*  'a206'  %main
          'Urbit from the Outside in'
          'Urbit Foundation CTO Ted Blackman and Staff Engineer Joe Bryan are two of the longest-standing developers in the Urbit ecosystem: they\'ve forgotten more about Hoon than most men have ever known. Rick Dudley, co-founder at Laconic is no Urbit insider, but he is a deeply knowledgeable founder and developer in the web3 space. Blackman and Bryan\'s task? To explain Urbit to Dudley from the outside in.'
          ''
          ~2023.10.29..11.00.00  ~h1
          %main
          ~['Rick Dudley' 'Ted Blackman' 'Joe Bryan']
          %panel
      ==
      :*  'a207'  %main
          'Rebooting the Arts'
          'The culture war is over—Culture lost. Now it\'s a race to build a new one. Media whisperer Ryan Lambert leads a conversation with Play Nice founder/impresario Hadrian Belove. trend forecaster Sean Monahan, and controversial art-doc collective Kirac. They discuss how to win the culture race, and create a new arts ecosystem out of the rubble.'
          ''
          ~2023.10.29..15.15.00  ~h1
          %main
          ~['Ryan Lambert' 'Hadrian Belove' 'Sean Monahan' 'Stefan Ruitenbeek']
          %panel
      ==
      :*  'a208'  %main
          'How to Fund a New World'
          'Cosimo de Medici persuaded Benvenuto Cellini, the Florentine sculptor, to enter his service by writing him a letter which concluded, \'Come, I will choke you with gold.\' Join UF Director of Markets Andrew Kim as he discusses how to get more gold onto Urbit with Jake Brukhman of Coinfund, Jae Yang of Tacen, @BacktheBunny from RabbitX and Evan Fisher of Portal VC.'
          ''
          ~2023.10.29..16.30.00  ~h1
          %main
          ~['Andrew Kim' 'Jake Brukhman' 'Jae Yang' 'Evan Fisher' '@BacktheBunny']
          %panel
      ==
      :*  'a209'  %main
          'Near BOS x Urbit'
          ''
          ''
          ~2023.10.29..17.30.00  ~m45
          %main
          ~['Illia Polosukhin' 'Ted Blackman']
          %talk
      ==
      :*  'a210'  %main
          'Closing Talk'
          ''
          ''
          ~2023.10.29..18.15.00  ~m30
          %main
          ~['Owen Barnes']
          %talk
      ==
    ::
      :*  'a211'  %main
          '%alphabet'
          'Alphabet is building a prediction market on Urbit. In this talk, we will review the obstacles and potential for network effects through distributed systems, from futures trading platforms to data curation and beyond.'
          ''
          ~2023.10.29..14.00.00  ~m30
          %second
          ~['Christopher Colby' '~solsup-soplyd']
          %presentation
      ==
      :*  'a212'  %main
          'Portal'
          ''
          ''
          ~2023.10.29..14.30.00  ~m30
          %second
          ~['~toptyr-bilder']
          %presentation
      ==
      :*  'a213'  %main
          'Remilia Black Ops Division: The Art of Psyops'
          'An unveiling of secret internal operations in the Remilia Corporation and a discussion about information warfare, culture building, and the necessity of psyops in the age of the Network.'
          ''
          ~2023.10.29..13.00.00  ~m45
          %second
          ~['Lukas (computer)' 'Michael Dragovic']
          %talk
      ==
      :*  'a214'  %main
          'The world if'
          'For Assembly 2021, Tlon produced a limited run of t-shirts boasting a bold declaration: The internet is over if you want it. Two years later, we assess the idea. Can the internet ever be over? Do we actually want it to die, or is it just one iteration of the internet we\'re ready to put behind us? Where are the communities thriving today, and how would they change if platforms were to shift? Our panelists will discuss the ever shifting digital landscape, nascent technologies, and the communities leading the way.'
          ''
          ~2023.10.29..11.00.00  ~h1
          %second
          ~['Marisa Rowland' 'Ellie Hain' 'Simon Denny' 'Jose Mejia']
          %panel
      ==
      :*  'a215'  %main
          'Teleopunk – the anarchitecture of human renovation'
          'Sound money, sound computers,  sound bodies? As technology continues to reshape us and the way we interact, how can we meaningfully reclaim our sovereignty in order to make it out of the near future? ~hastuc-dibtux and ~tondes-sitrym discuss'
          ''
          ~2023.10.29..15.15.00  ~m30
          %second
          ~['Liam Fitzgerald' 'Jake Hamilton']
          %talk
      ==
      :*  'a216'  %main
          'Turf – The Birth of a New World'
          'Urbit now has its own 2D pixel-art metaverse, where anyone can explore and add to the burgeoning network of turfs. It\'s not just another chat app—it\'s free real estate.'
          ''
          ~2023.10.29..15.45.00  ~m30
          %second
          ~['John Hyde']
          %presentation
      ==
      :*  'a217'  %main
          'NEW WORK'
          'The limits and potential of online parainstitutional culture'
          ''
          ~2023.10.29..16.30.00  ~m45
          %second
          ~['Daniel Keller' 'Jon Rafman' 'Milady Sonora Sprite']
          %panel
      ==
      :*  'a218'  %main
          'The Vietnam Thesis and El Salvador Method'
          'A discussion on the game theory and outcome behind Western hostility to DeFi, and how Network States manifest and coordinate.'
          ''
          ~2023.10.29..17.15.00  ~m30
          %second
          ~['Dmitry (@BacktheBunny)']
          %talk
      ==
  ==
::
++  week-1  ::  30th
  ^~  ^-  (list [@ event])
  :~  ^-  [@ event]  :*  'w101'  %week
          'ARGO: Cyberhermetic Wetware'
          '~fabryx and Urmetica present the CyberHermetic Float Tank, ARGO, 10/30 - 11/3'
          'Urmetica invites you to transcend the limits of space and time in this float tank experience brought to you by the mysterious minds of ~fabryx. Float tank times will be raffled off in the Urmetica Urbit group starting 2 weeks before, DM ~todset-partug for admission.'
          ~2023.10.30  ~  ::TODO  by appointment
          ['Play Nice Playground' ~]
          `'https://sfo2.digitaloceanspaces.com/poldec-tonteg-content/poldec-tonteg/2023.9.26..22.50.24-230922_ARGO-Urbit-Assembly_flyer-A4_purple.png'
          'Float Tank'
          ~
      ==
      ^-  [@ event]  :*  'w102'  %week
          'UF Demo Day'
          'Demo Day is where our Assembly Hackathon and the u/acc accelerator culminate, giving you the first glance at community projects.'
          'This is an official side-event organized by the Urbit Foundation. The day will start with presentations from our Hackathon contestants. After lunch our committee of judges will announce the winners and present prizes. The u/acc pitches will be given in the afternoon to an invite-only group of qualified investors, but open areas for hanging out, networking, and giving lightning talks will be available throughout the afternoon.'
          ~2023.10.30..09.00.00  `~h8
          ['TBA' ~]
          ~
          'Demo Day'
          %-  some
          :-  'If you want to present at Demo Day, please fill out the form via the register button or reach out to ~dalweb-donfun.'
          ['Register ↗' 'https://docs.google.com/forms/d/e/1FAIpQLSfOg70Rf1GqBjPIHJ0ZhgKJbpbWsL4Nixlgd7tMOAspUcajBg/viewform?usp=sf_link']
      ==
      ^-  [@ event]  :*  'w103'  %week
          'SovHouse Lisboa'
          'Sovereign House NY comes to Lisboa, 10/30 - 11/3'
          'The minds behind Sovereign House NY are coming to Portugal. Located in the heart of historic Lisbon, you\'ll find SovHouse Lisboa; a daytime clubhouse to reconnoiter, grab an espresso and a cigarette and scheme.'
          ~2023.10.30  ~
          ['Historic Lisboa' ~]
          `'https://sfo2.digitaloceanspaces.com/poldec-tonteg-content/poldec-tonteg/2023.9.19..02.42.41-sovhouse%20lisboa-2.png'
          'Lounge'
          ~
      ==
      ^-  [@ event]  :*  'w104'  %week
          'MRB: Portuguese Nights'
          'Mingle with literary superstars from across the Urbit extended universe and celebrate the release of a new issue of the finest magazine on Mars.'
          ''
          ~2023.10.30..17.00.00  ~
          ['SovHouse Lisboa' ~]
          ~
          'Reading/Party'
          ~
      ==
  ==
::
++  week-2  ::  31st
  ^~  ^-  (list [@ event])
  :~  :*  'w201'  %week
          'ARGO: Cyberhermetic Wetware'
          '~fabryx and Urmetica present the CyberHermetic Float Tank, ARGO, 10/30 - 11/3'
          'Urmetica invites you to transcend the limits of space and time in this float tank experience brought to you by the mysterious minds of ~fabryx. Float tank times will be raffled off in the Urmetica Urbit group starting 2 weeks before, DM ~todset-partug for admission.'
          ~2023.10.31  ~  ::TODO  by appointment
          ['Play Nice Playground' ~]
          `'https://sfo2.digitaloceanspaces.com/poldec-tonteg-content/poldec-tonteg/2023.9.26..22.50.24-230922_ARGO-Urbit-Assembly_flyer-A4_purple.png'
          'Float Tank'
          ~
      ==
      :*  'w202'  %week
          'Manifesto Brunch'
          'A roof top brunch with the Native Planet team featuring our new Self Hosting Manifesto.'
          'Get your day started off right and join the Native Planet team for roof-top coffee, mimosas, and pastries. We will be hanging out and discussing self-hosting maximalism and the publication of our manifesto, \'Improvised Computational Munitions\''
          ~2023.10.31..10.00.00  `~h2
          ['Noobai - Rooftop Bar e Restaurante' ~]
          `'https://s3.dalhec-banler.startram.io/bucket/dalhec-banler/2023.10.04..18.44.33-Manifesto%20Brunch.jpg'
          'Brunch'
          `['' 'Link ↗' 'https://www.nativeplanet.io/manifesto-brunch']
      ==
      :*  'w203'  %week
          'The Future of Mellow Air Travel with BlimpDAO'
          'Mellow Air Travel and Calm Computing: a talk with Alan Shrimpton, editor of AIRSHIP Journal'
          'Join BlimpDAO at SovHouse for jazz music, tinkling glassware and an address by Alan Shrimpton, airship expert and editor of the premier journal of lighter than air travel.\0aDress code: Tycoon'
          ~2023.10.31..14.00.00  `~h2
          ['SovHouse Lisboa' ~]
          `'https://i.giphy.com/media/KOKDyMgMjZ7sxg9v2i/giphy-downsized-large.gif'
          'Cocktail Party'
          `['' 'Link ↗' 'https://lu.ma/agqp95k2']
      ==
      :*  'w204'  %week
          'Halloween House Party'
          'It\'s a monster mash'
          'Join us for a night of spooky fun and lighthearted cultural imperialism as we bring this most American of holidays to Iberian shores. Awards will be given for best and worst costume.'
          ~2023.10.31..20.00.00  ~
          ['SovHouse Lisboa' ~]
          `'https://sfo2.digitaloceanspaces.com/poldec-tonteg-content/poldec-tonteg/2023.10.17..22.39.55-image.png'
          'Party'
          `['' 'Link ↗' 'https://partiful.com/e/K9HUtFe7JyvgOBynFwgl']
      ==
      :*  'w205'  %week
          'SovHouse Lisboa'
          'Sovereign House NY comes to Lisboa, 10/30 - 11/3'
          'The minds behind Sovereign House NY are coming to Portugal. Located in the heart of historic Lisbon, you\'ll find SovHouse Lisboa; a daytime clubhouse to reconnoiter, grab an espresso and a cigarette and scheme.'
          ~2023.10.31  ~
          ['Historic Lisboa' ~]
          `'https://sfo2.digitaloceanspaces.com/poldec-tonteg-content/poldec-tonteg/2023.9.19..02.42.41-sovhouse%20lisboa-2.png'
          'Lounge'
          ~
      ==
  ==
::
++  week-3  ::  nov 1st
  ^~  ^-  (list [@ event])
  :~  :*  'w301'  %week
          'ARGO: Cyberhermetic Wetware'
          '~fabryx and Urmetica present the CyberHermetic Float Tank, ARGO, 10/30 - 11/3'
          'Urmetica invites you to transcend the limits of space and time in this float tank experience brought to you by the mysterious minds of ~fabryx. Float tank times will be raffled off in the Urmetica Urbit group starting 2 weeks before, DM ~todset-partug for admission.'
          ~2023.11.1  ~  ::TODO  by appointment
          ['Play Nice Playground' ~]
          `'https://sfo2.digitaloceanspaces.com/poldec-tonteg-content/poldec-tonteg/2023.9.26..22.50.24-230922_ARGO-Urbit-Assembly_flyer-A4_purple.png'
          'Float Tank'
          ~
      ==
      :*  'w302'  %week
          'Excursions'
          'A day-long workshop, algorithmic rave and live NFT mint. IRL and on Urbit.'
          'The first half of the day is a hackathon / workshop introducing the Hydra live coding visual environment and the agent we\'ve built to introduce Hydra compatibility on Urbit. The second half of the day is an ambient chill out room in which community members perform their live Hydra sets alongside special musical guests.'
          ~2023.11.1..14.00.00  `~h7
          ['Urbit After Hours' ~]
          `'https://i.giphy.com/media/7nWUjXgFU4OUcR4ErX/giphy-downsized-large.gif'
          'Wellness Rave'
          `['' 'Link ↗' 'https://lu.ma/sym4u2hd']
      ==
      :*  'w303'  %week
          'All Saints Day Fatima Pilgrimage'
          'Join other Catholic Martians at Fatima on All Saints Day.'
          'We\'ll travel to Fatima on All Saints Day to make a pilgrimage and attend Mass. Mass times at the basilica and chapel (https://www.fatima.pt/en/schedule), SSPX low Mass is at 4PM. (https://www.fsspx.es/es/capela-do-imaculado-cora%C3%A7%C3%A3o-de-maria) You will need to arrange your own transport to Fatima. Coordinate meeting up in the Assembly channel in ~darduc-mitfen/catholicism. As a backup join the Signal group (https://signal.group/#CjQKIDShtD1ZzvyUmG5nu3R0hrbv3qrfCAhwGe-xqiPG_EgGEhAjyWizHvWA7D1Q1guAie-h)'
          ~2023.11.1..14.00.00  `~h7
          ['The Sanctuary of Fátima ' ~]
          `'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/Igreja_Matriz_de_F%C3%A1tima_-_Portugal_%2821418731630%29.jpg/2880px-Igreja_Matriz_de_F%C3%A1tima_-_Portugal_%2821418731630%29.jpg'
          'Pilgrimage'
          ~
      ==
      :*  'w304'  %week
          'SovHouse Lisboa'
          'Sovereign House NY comes to Lisboa, 10/30 - 11/3'
          'The minds behind Sovereign House NY are coming to Portugal. Located in the heart of historic Lisbon, you\'ll find SovHouse Lisboa; a daytime clubhouse to reconnoiter, grab an espresso and a cigarette and scheme.'
          ~2023.11.1  ~
          ['Historic Lisboa' ~]
          `'https://sfo2.digitaloceanspaces.com/poldec-tonteg-content/poldec-tonteg/2023.9.19..02.42.41-sovhouse%20lisboa-2.png'
          'Lounge'
          ~
      ==
  ==
::
++  week-4  ::  nov 2nd
  ^~  ^-  (list [@ event])
  :~  :*  'w401'  %week
          'ARGO: Cyberhermetic Wetware'
          '~fabryx and Urmetica present the CyberHermetic Float Tank, ARGO, 10/30 - 11/3'
          'Urmetica invites you to transcend the limits of space and time in this float tank experience brought to you by the mysterious minds of ~fabryx. Float tank times will be raffled off in the Urmetica Urbit group starting 2 weeks before, DM ~todset-partug for admission.'
          ~2023.11.2  ~  ::TODO "By Appointment",
          ['Play Nice Playground' ~]
          `'https://sfo2.digitaloceanspaces.com/poldec-tonteg-content/poldec-tonteg/2023.9.26..22.50.24-230922_ARGO-Urbit-Assembly_flyer-A4_purple.png'
          'Float Tank'
          ~
      ==
      :*  'w402'  %week
          'Poker Night'
          'Transatlantic card game'
          'Come join the gentlemen from SovHouse and Giga Corp for a night of glitz, glamor and losing your lunch money.'
          ~2023.11.2..20.00.00  ~  ::TODO  "Night",
          ['SovHouse Lisboa' ~]
          ~
          'Poker'
          ~
      ==
      :*  'w403'  %week
          'SovHouse Lisboa'
          'Sovereign House NY comes to Lisboa, 10/30 - 11/3'
          'The minds behind Sovereign House NY are coming to Portugal. Located in the heart of historic Lisbon, you\'ll find SovHouse Lisboa; a daytime clubhouse to reconnoiter, grab an espresso and a cigarette and scheme.'
          ~2023.11.2  ~
          ['Historic Lisboa' ~]
          `'https://sfo2.digitaloceanspaces.com/poldec-tonteg-content/poldec-tonteg/2023.9.19..02.42.41-sovhouse%20lisboa-2.png'
          'Lounge'
          ~
      ==
      :*  'w404'  %week
          'Galaxy Brain Chess Tournament'
          'A casual outdoor chess tournament with a view'
          'Come test your skill in the game of kings against fellow Urbiters and unsuspecting bystanders. Winner and runner-up eligible for prizes and bragging rights.'
          ~2023.11.2..11.00.00  ~
          ['Jardim Botto Machado' ~]
          `'https://sfo2.digitaloceanspaces.com/poldec-tonteg-content/poldec-tonteg/2023.9.19..02.28.55-galaxy%20brain.png'
          'Chess'
          ~
      ==
  ==
::
++  week-5
  ^~  ^-  (list [@ event])
  :~  :*  'w501'  %week
          'SovHouse Lisboa'
          'Sovereign House NY comes to Lisboa, 10/30 - 11/3'
          'The minds behind Sovereign House NY are coming to Portugal. Located in the heart of historic Lisbon, you\'ll find SovHouse Lisboa; a daytime clubhouse to reconnoiter, grab an espresso and a cigarette and scheme.'
          ~2023.11.3  ~
          ['Historic Lisboa' ~]
          `'https://sfo2.digitaloceanspaces.com/poldec-tonteg-content/poldec-tonteg/2023.9.19..02.42.41-sovhouse%20lisboa-2.png'
          'Lounge'
          ~
      ==
      :*  'w502'  %week
          'ARGO: Cyberhermetic Wetware'
          '~fabryx and Urmetica present the CyberHermetic Float Tank, ARGO, 10/30 - 11/3'
          'Urmetica invites you to transcend the limits of space and time in this float tank experience brought to you by the mysterious minds of ~fabryx. Float tank times will be raffled off in the Urmetica Urbit group starting 2 weeks before, DM ~todset-partug for admission.'
          ~2023.11.3  ~  ::TODO "By Appointment",
          ['Play Nice Playground' ~]
          `'https://sfo2.digitaloceanspaces.com/poldec-tonteg-content/poldec-tonteg/2023.9.26..22.50.24-230922_ARGO-Urbit-Assembly_flyer-A4_purple.png'
          'Float Tank'
          ~
      ==
  ==
::
--